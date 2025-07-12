use std::io::{self, Write};
use std::ffi::{CString, CStr};

unsafe extern "C" {
    fn hello();
    fn sum(a: usize, b: usize) -> usize;
    fn file_size(filename: *const i8) -> i64;
    fn shell();
    fn write_mmap(text: *const u8) -> *const u8;
    fn write_file_mmap(filename: *const i8) -> *const u8;
}

fn main() {
    unsafe {
        loop {
            println!("Menu:");
            println!("1) Hello world");
            println!("2) Sum two numbers");
            println!("3) Get file size");
            println!("4) Exec Shell");
            println!("5) Write on memory");
            println!("6) Map file to memory and edit");
            println!("0) Exit");
            print!("Choose an option: ");
            io::stdout().flush().unwrap();

            let mut input = String::new();
            io::stdin().read_line(&mut input).unwrap();
            let choice = input.trim();

            match choice {
                "1" => {
                    hello();
                }
                "2" => {
                    println!("Enter two numbers:");
                    let mut a_str = String::new();
                    let mut b_str = String::new();
                    io::stdin().read_line(&mut a_str).unwrap();
                    io::stdin().read_line(&mut b_str).unwrap();
                    let a = a_str.trim().parse::<usize>().unwrap_or(0);
                    let b = b_str.trim().parse::<usize>().unwrap_or(0);
                    let result = sum(a, b);
                    println!("Sum result: {}", result);
                }
                "3" => { 
                    println!("Enter filename:");
                    let mut filename_input = String::new();
                    io::stdin().read_line(&mut filename_input).unwrap();
                    let filename_trimmed = filename_input.trim_end();
                    let filename_cstring = CString::new(filename_trimmed).expect("CString::new failed");
                    let size = file_size(filename_cstring.as_ptr());
                    if size < 0 {
                        println!("File not found");
                    } else {
                        println!("Size: {}", size);
                    }
                }
                "4" => {
                   shell();
                }
                "5" => {
                    println!("Enter text:");
                    let mut text_input = String::new();
                    io::stdin().read_line(&mut text_input).unwrap();

                    let text_trimmed = text_input.trim_end();
                    let text_cstring = CString::new(text_trimmed).expect("CString::new failed");

                    let addr = write_mmap(text_cstring.as_ptr() as *const u8);
                    let cstr = CStr::from_ptr(addr as *const i8);
                    println!("Address: {:?}", addr);
                    println!("Written text: {}", cstr.to_str().unwrap());
                }
                "6" => {
                    println!("Enter filename:");
                    let mut filename_input = String::new();
                    io::stdin().read_line(&mut filename_input).unwrap();
                    let filename_trimmed = filename_input.trim_end();
                    let filename_cstring = CString::new(filename_trimmed).expect("CString::new failed");
                    let file_ptr = write_file_mmap(filename_cstring.as_ptr());
                    let size = file_size(filename_cstring.as_ptr()) as usize;
                    let mmap_slice = std::slice::from_raw_parts_mut(file_ptr as *mut u8, size);
                    
                    println!("Enter the string to replace:");
                    let mut from_input = String::new();
                    io::stdin().read_line(&mut from_input).unwrap();
                    let from = from_input.trim_end().as_bytes();

                    println!("Enter the new string:");
                    let mut to_input = String::new();
                    io::stdin().read_line(&mut to_input).unwrap();
                    let to = to_input.trim_end().as_bytes();

                    for i in 0..=size - from.len() {
                        if &mmap_slice[i..i + from.len()] == from {
                            mmap_slice[i..i + to.len()].copy_from_slice(to);
                        }
                    }
                    let cstr = CStr::from_ptr(file_ptr as *const i8);
                    println!("Address: {:?}", file_ptr);
                    println!("File: \n{}", cstr.to_str().unwrap());
                }
                "0" => break,
                _ => println!("Invalid option"),
            }

            println!();
        }
    }
}
