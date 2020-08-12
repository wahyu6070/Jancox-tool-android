import os
import sys
import struct
import traceback
import shutil

EXT4_HEADER_MAGIC = 0xED26FF3A
EXT4_SPARSE_HEADER_LEN = 28
EXT4_CHUNK_HEADER_SIZE = 12


class ext4_file_header(object):
    def __init__(self, buf):
        (self.magic,
         self.major,
         self.minor,
         self.file_header_size,
         self.chunk_header_size,
         self.block_size,
         self.total_blocks,
         self.total_chunks,
         self.crc32) = struct.unpack('<I4H4I', buf)


class ext4_chunk_header(object):
    def __init__(self, buf):
        (self.type,
         self.reserved,
         self.chunk_size,
         self.total_size) = struct.unpack('<2H2I', buf)


class Extractor(object):
    def __init__(self):
        self.FileName = ""
        self.BASE_DIR = ""
        self.OUTPUT_IMAGE_FILE = ""
        self.EXTRACT_DIR = ""
        self.BLOCK_SIZE = 4096
        self.TYPE_IMG = 'system'
        self.context = []
        self.fsconfig = []

    def __remove(self, path):
        if os.path.isfile(path):
            os.remove(path)  # remove the file
        elif os.path.isdir(path):
            shutil.rmtree(path)  # remove dir and all contains
        else:
            raise ValueError("file {} is not a file or dir.".format(path))

    def __logtb(self, ex, ex_traceback=None):
        if ex_traceback is None:
            ex_traceback = ex.__traceback__
        tb_lines = [line.rstrip('\n') for line in
                    traceback.format_exception(ex.__class__, ex, ex_traceback)]
        return '\n'.join(tb_lines)

    def __file_name(self,file_path):
        name = os.path.basename(file_path).split('.')[0]
        name = name.split('-')[0]
        name = name.split('_')[0]
        name = name.split(' ')[0]
        return name

    def __appendf(self, msg, log_file):
        with open(log_file, 'a', newline='\n') as file:
            print(msg, file=file)

    def __getperm(self, arg):
        if len(arg) < 9 or len(arg) > 10:
            return
        if len(arg) > 8:
            arg = arg[1:]
        oor, ow, ox, gr, gw, gx, wr, ww, wx = list(arg)
        o, g, w, s = 0, 0, 0, 0
        if oor == 'r': o += 4
        if ow == 'w': o += 2
        if ox == 'x': o += 1
        if ox == 'S': s += 4
        if ox == 's': s += 4; o += 1
        if gr == 'r': g += 4
        if gw == 'w': g += 2
        if gx == 'x': g += 1
        if gx == 'S': s += 2
        if gx == 's': s += 2; g += 1
        if wr == 'r': w += 4
        if ww == 'w': w += 2
        if wx == 'x': w += 1
        if wx == 'T': s += 1
        if wx == 't': s += 1; w += 1
        return str(s) + str(o) + str(g) + str(w)

    def __ext4extractor(self):
        import ext4, string, struct
        #fs_config_file = self.FileName + '_statfile.txt'
        contexts = self.BASE_DIR + self.FileName + "_file_contexts" #08.05.18
        fs_config_file = self.FileName + '_fs_config'
        def scan_dir(root_inode, root_path=""):
            for entry_name, entry_inode_idx, entry_type in root_inode.open_dir():
                if entry_name in ['.', '..', 'lost+found'] or entry_name.endswith(' (2)'):
                    continue
                entry_inode = root_inode.volume.get_inode(entry_inode_idx, entry_type)
                entry_inode_path = root_path + '/' + entry_name
                mode = self.__getperm(entry_inode.mode_str)
                uid = entry_inode.inode.i_uid
                gid = entry_inode.inode.i_gid
                con = ''
                cap = ''
                for i in list(entry_inode.xattrs()):
                    if i[0] == 'security.selinux':
                        con = i[1].decode('utf8')[:-1]
                    elif i[0] == 'security.capability':
                        cap = ' capabilities=' + str(hex(struct.unpack("<IIIII", i[1])[1]))
                if entry_inode.is_dir:
                    dir_target = self.EXTRACT_DIR + entry_inode_path
                    if not os.path.isdir(dir_target):
                        os.makedirs(dir_target)
                    if os.name == 'posix':
                        os.chmod(dir_target, int(mode, 8))
                        os.chown(dir_target, uid, gid)
                    scan_dir(entry_inode, entry_inode_path)
                    if cap == '' and con == '':
                        self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode))
                    else:
                        if cap == '':
                            self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode))
                            if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                        else:
                            if con == '':
                                self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap))
                            else:
                                self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap))
                                if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                    self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                elif entry_inode.is_file:
                    try:
                        raw = entry_inode.open_read().read()
                    except:
                        continue
                    wdone = None
                    if os.name == 'nt':
                        if entry_name.endswith('/'):
                            entry_name = entry_name[:-1]
                        file_target = self.EXTRACT_DIR + entry_inode_path.replace('/', os.sep)
                        if not os.path.isdir(os.path.dirname(file_target)):
                            os.makedirs(os.path.dirname(file_target))
                        with open(file_target, 'wb') as out:
                            out.write(raw)
                    if os.name == 'posix':
                        file_target = self.EXTRACT_DIR + entry_inode_path
                        if not os.path.isdir(os.path.dirname(file_target)):
                            os.makedirs(os.path.dirname(file_target))
                        with open(file_target, 'wb') as out:
                            out.write(raw)
                        os.chmod(file_target, int(mode, 8))
                        os.chown(file_target, uid, gid)
                    if cap == '' and con == '':
                        self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode))
                    else:
                        if cap == '':
                            self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode))
                            if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                        else:
                            if con == '':
                                self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap))
                            else:
                                self.fsconfig.append('%s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap))
                                if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                    self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                elif entry_inode.is_symlink:
                    try:
                        link_target = entry_inode.open_read().read().decode("utf8")
                        target = self.EXTRACT_DIR + entry_inode_path
                        if cap == '' and con == '':
                            self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode, link_target))
                        else:
                            if cap == '':
                                self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode, link_target))
                                if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                    self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                            else:
                                if con == '':
                                    self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap, link_target))
                                else:
                                    self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap, link_target))
                                    if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                        self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                        if os.path.islink(target):
                            try:
                                os.remove(target)
                            except:
                                pass
                        if os.path.isfile(target):
                            try:
                                os.remove(target)
                            except:
                                pass
                        if os.name == 'posix':
                            os.symlink(link_target, target)
                        if os.name == 'nt':
                            with open(target.replace('/', os.sep), 'wb') as out:
                                tmp = bytes.fromhex('213C73796D6C696E6B3EFFFE')
                                for index in list(link_target):
                                    tmp = tmp + struct.pack('>sx', index.encode('utf-8'))
                                out.write(tmp + struct.pack('xx'))
                                os.system('attrib +s "%s"' % target.replace('/', os.sep))
                        if not all(c in string.printable for c in link_target):
                            pass
                        if entry_inode_path[1:] == entry_name or link_target[1:] == entry_name:
                            self.symlinks.append('%s %s' % (link_target, entry_inode_path[1:]))
                        else:
                            self.symlinks.append('%s %s' % (link_target, self.DIR + entry_inode_path))
                    except:
                        try:
                            link_target_block = int.from_bytes(entry_inode.open_read().read(), "little")
                            link_target = root_inode.volume.read(link_target_block * root_inode.volume.block_size, entry_inode.inode.i_size).decode("utf8")
                            target = self.EXTRACT_DIR + entry_inode_path
                            if link_target and all(c in string.printable for c in link_target):
                                if cap == '' and con == '':
                                    self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode, link_target))
                                else:
                                    if cap == '':
                                        self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode, link_target))
                                        if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                            self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                                    else:
                                        if con == '':
                                            self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap, link_target))
                                        else:
                                            self.fsconfig.append('%s %s %s %s %s' % (self.DIR + entry_inode_path, uid, gid, mode + cap, link_target))
                                            if con != 'u:object_r:' + self.FileName + '_file:s0':#11.05.18
                                                self.context.append('/%s %s' % (self.DIR + entry_inode_path, con))
                                if os.name == 'posix':
                                    os.symlink(link_target, target)
                                if os.name == 'nt':
                                    with open(target.replace('/', os.sep), 'wb') as out:
                                        tmp = bytes.fromhex('213C73796D6C696E6B3EFFFE')
                                        for index in list(link_target):
                                            tmp = tmp + struct.pack('>sx', index.encode('utf-8'))
                                        out.write(tmp + struct.pack('xx'))
                                        os.system('attrib +s %s' % target.replace('/', os.sep))
                            else:
                                pass
                        except:
                            pass

        f = open(self.EXTRACT_DIR + '_size.txt', 'tw', encoding='utf-8')
        self.__appendf(os.path.getsize(self.OUTPUT_IMAGE_FILE), self.EXTRACT_DIR + '_size.txt')
        f.close()
        with open(self.OUTPUT_IMAGE_FILE, 'rb') as file:
            root = ext4.Volume(file).root
            dirlist = []
            for file_name, inode_idx, file_type in root.open_dir():
                dirlist.append(file_name)
            dirr = self.__file_name(os.path.basename(self.OUTPUT_IMAGE_FILE).split('.')[0]) #11.05.18
            setattr(self, 'DIR', dirr)
            if dirr == 'system':
                self.fsconfig = [dirr +'/lost+found 0 0 0700']#11.05.18
            elif dirr == 'vendor':
                self.fsconfig = [dirr +'/lost+found 0 0 0700']#11.05.18
            self.context = ['/' + dirr + '(/.*)? u:object_r:' + dirr + '_file:s0']#11.05.18
            scan_dir(root)
            self.fsconfig.sort()
            self.__appendf('\n'.join(self.fsconfig), self.BASE_DIR + os.sep + fs_config_file)
            if self.context:#11.05.18
                self.context.sort()#11.05.18
                self.__appendf('\n'.join(self.context), contexts)#11.05.18

    def __converSimgToImg(self, target):
        with open(target, "rb") as img_file:
            if self.sign_offset > 0:
                img_file.seek(self.sign_offset, 0)
            header = ext4_file_header(img_file.read(28))
            total_chunks = header.total_chunks
            if header.file_header_size > EXT4_SPARSE_HEADER_LEN:
                img_file.seek(header.file_header_size - EXT4_SPARSE_HEADER_LEN, 1)
            with open(target.replace(".img", ".raw.img"), "wb") as raw_img_file:
                sector_base = 82528
                output_len = 0
                while total_chunks > 0:
                    chunk_header = ext4_chunk_header(img_file.read(EXT4_CHUNK_HEADER_SIZE))
                    sector_size = (chunk_header.chunk_size * header.block_size) >> 9
                    chunk_data_size = chunk_header.total_size - header.chunk_header_size
                    if chunk_header.type == 0xCAC1:  # CHUNK_TYPE_RAW
                        if header.chunk_header_size > EXT4_CHUNK_HEADER_SIZE:
                            img_file.seek(header.chunk_header_size - EXT4_CHUNK_HEADER_SIZE, 1)
                        data = img_file.read(chunk_data_size)
                        len_data = len(data)
                        if len_data == (sector_size << 9):
                            raw_img_file.write(data)
                            output_len += len_data
                            sector_base += sector_size
                    else:
                        if chunk_header.type == 0xCAC2:  # CHUNK_TYPE_FILL
                            if header.chunk_header_size > EXT4_CHUNK_HEADER_SIZE:
                                img_file.seek(header.chunk_header_size - EXT4_CHUNK_HEADER_SIZE, 1)
                            data = img_file.read(chunk_data_size)
                            len_data = sector_size << 9
                            raw_img_file.write(struct.pack("B", 0) * len_data)
                            output_len += len(data)
                            sector_base += sector_size
                        else:
                            if chunk_header.type == 0xCAC3:  # CHUNK_TYPE_DONT_CARE
                                if header.chunk_header_size > EXT4_CHUNK_HEADER_SIZE:
                                    img_file.seek(header.chunk_header_size - EXT4_CHUNK_HEADER_SIZE, 1)
                                data = img_file.read(chunk_data_size)
                                len_data = sector_size << 9
                                raw_img_file.write(struct.pack("B", 0) * len_data)
                                output_len += len(data)
                                sector_base += sector_size
                            else:
                                len_data = sector_size << 9
                                raw_img_file.write(struct.pack("B", 0) * len_data)
                                sector_base += sector_size
                    total_chunks -= 1
        # if os.path.exists(target):
        #    self.__remove(target)
        # os.rename(target.replace(".img", ".raw.img"), target)

        self.OUTPUT_IMAGE_FILE = target.replace(".img", ".raw.img")

    def checkSignOffset(self, file):
        import mmap
        mm = mmap.mmap(file.fileno(), 52428800, access=mmap.ACCESS_READ)  # 52428800=50Mb
        offset = mm.find(struct.pack('<L', EXT4_HEADER_MAGIC))
        return offset

    def __getTypeTarget(self, target):
        filename, file_extension = os.path.splitext(target)
        if file_extension == '.img':
            with open(target, "rb") as img_file:
                setattr(self, 'sign_offset', self.checkSignOffset(img_file))
                if self.sign_offset > 0:
                    img_file.seek(self.sign_offset, 0)
                header = ext4_file_header(img_file.read(28))
                if header.magic != EXT4_HEADER_MAGIC:
                    return 'img'
                else:
                    return 'simg'

    def main(self, target, output_dir):
        self.BASE_DIR = (os.path.realpath(os.path.dirname(target)) + os.sep)
        self.EXTRACT_DIR = os.path.realpath(os.path.dirname(output_dir)) + os.sep + self.__file_name(os.path.basename(output_dir)) #output_dir
        self.OUTPUT_IMAGE_FILE = self.BASE_DIR + os.path.basename(target)
        self.FileName = self.__file_name(os.path.basename(target))
        target_type = self.__getTypeTarget(target)
        if target_type == 'simg':
            print("Convert %s to %s" % (os.path.basename(target), os.path.basename(target).replace(".img", ".raw.img")))
            self.__converSimgToImg(target)
            print("Extraction from %s to %s" % (os.path.basename(target), os.path.basename(self.EXTRACT_DIR)))
            self.__ext4extractor()
        if target_type == 'img':
            print("Extraction from %s to %s" % (os.path.basename(target), os.path.basename(self.EXTRACT_DIR)))
            self.__ext4extractor()


if __name__ == '__main__':
    if sys.argv.__len__() == 3:
        Extractor().main(sys.argv[1], sys.argv[2])
    else:
        if sys.argv.__len__() == 2:
            Extractor().main(sys.argv[1], os.path.realpath(os.path.dirname(sys.argv[1])) + os.sep + os.path.basename(sys.argv[1]).split('.')[0])
        else:
            print("Must be at least 1 argument...")
            sys.exit(1)
