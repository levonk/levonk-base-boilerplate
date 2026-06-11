use anyhow::Result;
use std::sync::{Arc, Mutex};

/// Terminal size information
#[derive(Debug, Clone, Copy)]
pub struct TerminalSize {
    pub rows: u16,
    pub cols: u16,
}

impl TerminalSize {
    /// Create a new terminal size
    pub fn new(rows: u16, cols: u16) -> Self {
        Self { rows, cols }
    }

    /// Get default terminal size (fallback)
    pub fn default() -> Self {
        Self { rows: 24, cols: 80 }
    }

    /// Check if terminal is small
    pub fn is_small(&self) -> bool {
        self.cols < 80 || self.rows < 24
    }

    /// Check if terminal is wide
    pub fn is_wide(&self) -> bool {
        self.cols >= 120
    }
}

/// Terminal information
#[derive(Debug, Clone)]
pub struct TerminalInfo {
    pub size: TerminalSize,
    pub is_tty: bool,
    pub supports_color: bool,
}

impl TerminalInfo {
    /// Create new terminal info
    pub fn new(size: TerminalSize, is_tty: bool, supports_color: bool) -> Self {
        Self {
            size,
            is_tty,
            supports_color,
        }
    }

    /// Detect terminal information
    pub fn detect() -> Self {
        let is_tty = atty::is(atty::Stream::Stdout);
        let supports_color = is_tty && std::env::var("NO_COLOR").is_err();
        let size = if is_tty {
            get_terminal_size().unwrap_or_else(|_| TerminalSize::default())
        } else {
            TerminalSize::default()
        };

        Self::new(size, is_tty, supports_color)
    }
}

/// Get terminal size
pub fn get_terminal_size() -> Result<TerminalSize> {
    #[cfg(unix)]
    {
        use libc::{ioctl, TIOCGWINSZ, winsize};

        unsafe {
            let mut size: winsize = std::mem::zeroed();
            if ioctl(libc::STDOUT_FILENO, TIOCGWINSZ, &mut size) == 0 {
                if size.ws_row > 0 && size.ws_col > 0 {
                    return Ok(TerminalSize::new(size.ws_row, size.ws_col));
                }
            }
        }
        Err(anyhow::anyhow!("Failed to get terminal size"))
    }

    #[cfg(windows)]
    {
        use windows_sys::Win32::System::Console::{
            GetConsoleScreenBufferInfo, CONSOLE_SCREEN_BUFFER_INFO, HANDLE,
        };

        unsafe {
            let handle = GetStdHandle(windows_sys::Win32::System::Console::STD_OUTPUT_HANDLE);
            if handle != -1i32 as HANDLE {
                let mut info: CONSOLE_SCREEN_BUFFER_INFO = std::mem::zeroed();
                if GetConsoleScreenBufferInfo(handle, &mut info) != 0 {
                    let cols = info.srWindow.Right - info.srWindow.Left + 1;
                    let rows = info.srWindow.Bottom - info.srWindow.Top + 1;
                    if rows > 0 && cols > 0 {
                        return Ok(TerminalSize::new(rows as u16, cols as u16));
                    }
                }
            }
        }
        Err(anyhow::anyhow!("Failed to get terminal size"))
    }

    #[cfg(not(any(unix, windows)))]
    {
        Err(anyhow::anyhow!("Terminal size detection not supported on this platform"))
    }
}

/// Terminal resize handler
pub struct ResizeHandler {
    current_size: Arc<Mutex<TerminalSize>>,
}

impl ResizeHandler {
    /// Create a new resize handler
    pub fn new() -> Self {
        let initial_size = get_terminal_size().unwrap_or_else(|_| TerminalSize::default());
        Self {
            current_size: Arc::new(Mutex::new(initial_size)),
        }
    }

    /// Get current terminal size
    pub fn get_size(&self) -> TerminalSize {
        *self.current_size.lock().unwrap()
    }

    /// Update terminal size (call on resize events)
    pub fn update_size(&self) -> Result<()> {
        let new_size = get_terminal_size()?;
        *self.current_size.lock().unwrap() = new_size;
        Ok(())
    }

    /// Start listening for resize events (platform-specific)
    #[cfg(unix)]
    pub fn start_listener(&self) -> Result<()> {
        use signal_hook::consts::SIGWINCH;
        use signal_hook::iterator::Signals;

        let current_size = self.current_size.clone();
        let mut signals = Signals::new([SIGWINCH])?;

        std::thread::spawn(move || {
            for _ in signals.forever() {
                if let Ok(new_size) = get_terminal_size() {
                    *current_size.lock().unwrap() = new_size;
                }
            }
        });

        Ok(())
    }

    #[cfg(not(unix))]
    pub fn start_listener(&self) -> Result<()> {
        // Resize event handling not supported on this platform
        Ok(())
    }
}

impl Default for ResizeHandler {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_terminal_size_default() {
        let size = TerminalSize::default();
        assert_eq!(size.rows, 24);
        assert_eq!(size.cols, 80);
    }

    #[test]
    fn test_terminal_size_creation() {
        let size = TerminalSize::new(40, 120);
        assert_eq!(size.rows, 40);
        assert_eq!(size.cols, 120);
    }

    #[test]
    fn test_terminal_size_checks() {
        let small = TerminalSize::new(20, 60);
        assert!(small.is_small());
        assert!(!small.is_wide());

        let wide = TerminalSize::new(30, 140);
        assert!(!wide.is_small());
        assert!(wide.is_wide());

        let normal = TerminalSize::new(30, 100);
        assert!(!normal.is_small());
        assert!(!normal.is_wide());
    }

    #[test]
    fn test_terminal_info_detect() {
        let info = TerminalInfo::detect();
        // Just ensure it doesn't panic
        assert!(info.size.rows > 0 || info.size.cols > 0);
    }

    #[test]
    fn test_resize_handler() {
        let handler = ResizeHandler::new();
        let size = handler.get_size();
        assert!(size.rows > 0);
        assert!(size.cols > 0);
    }
}
