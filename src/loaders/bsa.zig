const std = @import("std");

const bsa_log = std.log.scoped(.BSA);

const BSA: [4]u8 = .{ 'B', 'S', 'A', 0 };

pub const Asset = struct {
    header: Header,
    folder_records: std.ArrayList(FolderRecord),

    pub fn delete(self: *Asset, allocator: std.mem.Allocator) void {
        self.folder_records.deinit(allocator);
    }
};

pub fn load(path: []const u8, io: std.Io) !void {
    // init allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var asset: Asset = undefined;
    defer asset.delete(allocator);

    // init file reader
    var file_buffer: [1024]u8 = undefined;
    var file: std.Io.File = try std.Io.Dir.openFile(std.Io.Dir.cwd(), io, path, .{ .mode = .read_only });
    defer file.close(io);

    var file_reader: std.Io.File.Reader = file.reader(io, &file_buffer);
    const reader: *std.Io.Reader = &file_reader.interface;

    // check magic word
    const file_id = reader.peekArray(4) catch |err| {
        if (err == error.EndOfStream) {
            bsa_log.err("file {s} not a BSA file", .{path});
        } else {
            bsa_log.err("{}", .{err});
        }
        return;
    };

    if (std.mem.eql(u8, file_id, &BSA) == false) {
        bsa_log.err("file {s} not a BSA file", .{path});
        return;
    }

    // read header
    asset.header = try reader.takeStruct(Header, .little);
    bsa_log.debug("header: {}", .{asset.header});

    // folder record
    asset.folder_records = try .initCapacity(allocator, asset.header.folder_count);
    for (0..asset.header.folder_count) |i| {
        const folder_rec = try reader.takeStruct(FolderRecord, .little);
        try asset.folder_records.append(allocator, folder_rec);

        //bsa_log.debug("folder record[{}]: {}", .{ i, folder_rec });
        _ = i;
    }

    for (0..asset.header.folder_count) |i| {
        // file record block
        try file_reader.seekTo(asset.folder_records.items[i].offset - asset.header.max_file_name);

        const str_size = try reader.takeInt(u8, .little);
        const folder_name: []const u8 = (try reader.take(str_size))[0..str_size];
        bsa_log.debug("Folder name: {s}", .{folder_name});

        // file record
        for (0..asset.folder_records.items[0].file_count) |j| {
            const file_record = try reader.takeStruct(FileRecord, .little);
            _ = file_record;
            _ = j;
        }
    }
}

// the extern keyword is necessary for takeStruct to work (properly)
const Header = extern struct {
    file_id: [4]u8, // always BSA\x00"
    version: u32, // always 104?
    offset: u32, // always 36 (the @sizeOf(Header))
    archive_flags: u32,
    folder_count: u32,
    file_count: u32,
    max_folder_name: u32,
    max_file_name: u32,
    file_flags: u16,
    padding: u16,
};

const FolderRecord = extern struct {
    hash: u64,
    file_count: u32,
    //padding0: u32, // only in version 105
    offset: u32,
    //padding1: u32, // only in version 105
};

const FileRecord = extern struct {
    hash: u64,
    size: u32,
    offset_from_0: u32, // offset to data
};

// some temp tests just to check that the logger doesn't print trash values
// tip: run 'zig build test 2&> test.txt'
// note: logger also prints the null character (not visible in my terminal)
test "simple test" {
    std.testing.log_level = .debug;
    const io = std.testing.io;

    try load("assets/Fallout - Meshes.bsa", io);
    try load("assets/Fallout - Misc.bsa", io);
    try load("assets/Fallout - Sound.bsa", io);
    try load("assets/Fallout - Textures.bsa", io);
    try load("assets/Fallout - Textures2.bsa", io);
    try load("assets/Fallout - Voices1.bsa", io);
}
// as for the rest bsa files, later
