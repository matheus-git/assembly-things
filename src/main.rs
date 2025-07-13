use std::io::{self, Write};
use std::ffi::{CString, CStr};

unsafe extern "C" {
    fn hello();
    fn sum(a: usize, b: usize) -> usize;
    fn file_size(filename: *const i8) -> i64;
    fn shell();
    fn write_mmap(text: *const u8) -> *const u8;
    fn write_file_mmap(filename: *const i8) -> *const u8;
    fn fork() -> usize;
    fn pid() -> usize;
    fn exec_program(path: *const i8, argv: *const *const i8, envp: *const *const i8) -> isize;
    fn pipe();
    fn dup();
    fn tcp_server();
    fn bind_shell();
    fn write_fifo();
    fn read_fifo();
}

fn main() {
    unsafe {
        println!("Menu:");
        println!("1) Hello world");
        println!("2) Sum two numbers");
        println!("3) Get file size");
        println!("4) Exec Shell");
        println!("5) Write on memory");
        println!("6) Map file to memory and edit");
        println!("7) Fork current process");
        println!("8) Execute 'ls' in child process");
        println!("9) Hello from pipe");
        println!("10) Duplicate stdout and write hello");
        println!("11) Tcp server 127.0.0.1:4444");
        println!("12) Bind shell 127.0.0.1:4444");
        println!("13) Read from FIFO");
        println!("14) Write to FIFO");
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
                let cstr = CStr::from_ptr(file_ptr as *const i8);
                println!("File: \n{}", cstr.to_str().unwrap());
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
                println!("\nAddress: {:?}", file_ptr);
                println!("File: \n{}", cstr.to_str().unwrap());
            }
            "7" => {
                let fork_result = fork();
                let this_pid = pid();

                if fork_result == 0 {
                    std::process::exit(0);
                }

                println!("Parent PID (this process): {}", this_pid);
                println!("Child PID (from fork): {}", fork_result);
            }
            "8" => {
                let fork_result = fork();

                if fork_result == 0 {
                    let path = CString::new("/bin/ls").unwrap();
                    let arg0 = CString::new("ls").unwrap();
                    let arg1 = CString::new("-l").unwrap();
                    let argv = [arg0.as_ptr(), arg1.as_ptr(), std::ptr::null()];
                    let envp = [std::ptr::null::<i8>()];
                    exec_program(path.as_ptr(), argv.as_ptr(), envp.as_ptr());
                }
            }
            "9" => {
                pipe();
            }
            "10" => {
                dup();
            }
            "11" => {
                println!("Starting TCP server on 127.0.0.1:4444...");
                println!("In another terminal, run a command like: nc 127.0.0.1 4444");
                println!("You should receive a 'Hello, world!' message.");
                tcp_server();
            }
            "12" => {
                println!("Starting bind shell on 127.0.0.1:4444...");
                println!("In another terminal, run a command like: nc 127.0.0.1 4444");
                println!("You will get a shell session.");
                bind_shell();
            }
            "13" => {
                println!("Starting FIFO reader... Make sure to run write_fifo (option 14) in another terminal.");
                read_fifo();
            }
            "14" => {
                println!("Writing to FIFO... Make sure the FIFO reader (option 13) is running in another terminal.");
                write_fifo();
            }
            _ => {},
        }
        
    }
}
