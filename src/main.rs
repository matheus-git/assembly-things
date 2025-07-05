#[repr(C)]
struct PtrLen {
    ptr: *const u8,
    len: usize,
}

unsafe extern "C" {
    fn hello() -> PtrLen;
    fn sum(a: u64, b: u64) -> u64;
}

fn main() {
    unsafe {
        let result = hello();
        let slice = std::slice::from_raw_parts(result.ptr, result.len);
        let string = std::str::from_utf8(slice).unwrap();

        println!("{string}");
        let suma = sum(2,3);
        println!("{suma}");
    }
}
