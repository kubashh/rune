const build_html_text = @embedFile("./buildHtml.js");

pub const build_html_js_minified = minifyJs(build_html_text);

fn minifyJs(comptime str: *const [1995:0]u8) []const u8 {
    @setEvalBranchQuota(10_000); // adjust upward if needed

    var buf: [1995]u8 = undefined;

    for (str[0..], 0..) |char, j| {
        buf[j] = char;
    }

    var buf_len = removeComments(&buf, buf.len);
    buf_len = removeDoubleSpacesAndNL(&buf, buf_len);

    const copy = buf[0..buf_len].*;
    return &copy;
}

fn removeComments(comptime buf: []u8, buf_len: usize) usize {
    _ = buf_len;
    var i = 0;
    var prev: u8 = 0;
    var comment = false;
    for (buf) |char| {
        // comment
        if (comment) {
            if (char == '\n') {
                comment = false;
            } else continue;
        } else if (prev == '/' and char == '/') {
            comment = true;
            i -= 1;
            continue;
        }
        buf[i] = char;
        prev = char;
        i += 1;
    }
    return i;
}

fn removeDoubleSpacesAndNL(comptime buf: []u8, buf_len: usize) usize {
    // remove new lines, works only with semicollons

    var i: usize = 0;
    var prev: u8 = 0;
    for (buf[0..buf_len]) |char| {
        if (prev == ' ' and char == ' ' or char == '\n') {
            // i -= 1;
        } else {
            buf[i] = char;
            prev = char;
            i += 1;
        }
    }
    return i;
}
