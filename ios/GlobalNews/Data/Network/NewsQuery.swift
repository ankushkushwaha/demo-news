
struct NewsQuery {
    let q: String
    let hl: String
    let gl: String
    var ceid: String { "\(gl):\(String(hl.prefix(2)))" }
    
    init(q: String, hl: String = "en-US", gl: String = "US") {
        self.q = q
        self.hl = hl
        self.gl = gl
    }
}
