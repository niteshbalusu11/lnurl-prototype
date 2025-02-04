// Zig example of the use of the standard library HTTP client
// <https://ziglang.org/documentation/0.12.0/std/#std.http.Client> We
// retrieve JSON data from a network API. We are not very paranoid,
// more checks should be created.

const std = @import("std");

// The API we use
const ref_url = "https://localhost:8081/v1/getinfo";
const macaroon = "0201036c6e6402f801030a10158a203561b2898c9d0076307deac7031201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e65726174651204726561640000062017bc67c595b1e4f2cac65dbe5f3bb2ee2a4f1551e6f55c88a3adaf2449cfb454";
// Some values
const headers_max_size = 1024;
const body_max_size = 65536;

pub fn main() !void {
    const url = try std.Uri.parse(ref_url);

    // We need an allocator to create a std.http.Client
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    var client = std.http.Client{ .allocator = gpa };
    defer client.deinit();

    var hbuffer: [headers_max_size]u8 = undefined;
    const options = std.http.Client.RequestOptions{ .server_header_buffer = &hbuffer, .headers = .{}, .extra_headers = &[_]std.http.Header{.{ .name = "Grpc-metadata-macaroon", .value = macaroon }} };
    // Call the API endpoint
    var request = try client.open(
        std.http.Method.GET,
        url,
        options,
    );
    defer request.deinit();
    _ = try request.send();
    _ = try request.finish();
    _ = try request.wait();

    std.debug.print("Response status: {d}\n", .{request.response.status});

    // Check the HTTP return code
    if (request.response.status != std.http.Status.ok) {
        return error.WrongStatusResponse;
    }

    // Read the body
    var bbuffer: [body_max_size]u8 = undefined;
    const hlength = request.response.parser.header_bytes_len;
    _ = try request.readAll(&bbuffer);
    const blength = request.response.content_length orelse return error.NoBodyLength; // We trust
    // the Content-Length returned by the server…

    // Display the result
    std.debug.print("{d} header bytes returned:\n{s}\n", .{ hlength, hbuffer[0..hlength] });
    // The response is in JSON so we should here add JSON parsing code.
    std.debug.print("{d} body bytes returned:\n{s}\n", .{ blength, bbuffer[0..blength] });
}
