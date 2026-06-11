use anyhow::{Context, Result};
use signal_hook::consts::SIGHUP;
use signal_hook_tokio::Signals;
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::{info, error, debug};
use futures_util::stream::StreamExt;
use crate::config::ConfigManager;

/// Signal handler for configuration reload
pub struct SignalHandler {
    config_manager: Arc<Mutex<ConfigManager>>,
    reload_count: Arc<Mutex<u64>>,
}

impl SignalHandler {
    /// Create a new signal handler
    pub fn new(config_manager: Arc<Mutex<ConfigManager>>) -> Self {
        SignalHandler {
            config_manager,
            reload_count: Arc::new(Mutex::new(0)),
        }
    }

    /// Start listening for SIGHUP signals
    pub async fn run(&self) -> Result<()> {
        // Create signal stream for SIGHUP
        #[cfg(unix)]
        {
            let signals = Signals::new(&[SIGHUP])
                .context("Failed to create signal stream")?;

            info!("Signal handler started, listening for SIGHUP");

            // Clone Arcs for the async block
            let config_manager = self.config_manager.clone();
            let reload_count = self.reload_count.clone();

            tokio::spawn(async move {
                let mut signals = signals;
                while let Some(signal) = signals.next().await {
                    match signal {
                        SIGHUP => {
                            info!("Received SIGHUP signal, initiating config reload");
                            if let Err(e) = Self::reload_config(&config_manager).await {
                                error!("Config reload failed: {}", e);
                            } else {
                                let mut count = reload_count.lock().await;
                                *count += 1;
                                info!("Config reload completed successfully (total reloads: {})", *count);
                            }
                        }
                        _ => {
                            debug!("Received unexpected signal: {}", signal);
                        }
                    }
                }
            });
        }

        #[cfg(not(unix))]
        {
            warn!("Signal handling is only supported on Unix platforms");
        }

        Ok(())
    }

    /// Reload configuration from files
    async fn reload_config(config_manager: &Arc<Mutex<ConfigManager>>) -> Result<()> {
        // Clone old config for rollback
        let _old_config = {
            let manager = config_manager.lock().await;
            manager.config().clone()
        };

        // Attempt to reload configuration
        let mut manager = config_manager.lock().await;

        info!("Reloading configuration from all sources");

        // Reload using the manager's reload method
        manager.reload().context("Failed to reload configuration")?;

        // Validate new configuration
        manager.validate().context("New configuration validation failed")?;

        // Get new config for logging
        let new_config = manager.config().clone();

        info!("Configuration reloaded successfully");
        debug!("New config: log_level={}, color={}, output_format={}",
               new_config.log_level, new_config.color, new_config.output_format);

        Ok(())
    }

    /// Get the number of successful config reloads
    pub async fn reload_count(&self) -> u64 {
        *self.reload_count.lock().await
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;

    #[tokio::test]
    async fn test_signal_handler_creation() {
        let config_manager = Arc::new(Mutex::new(ConfigManager::new()));
        let handler = SignalHandler::new(config_manager);
        assert_eq!(handler.reload_count().await, 0);
    }

    #[tokio::test]
    async fn test_reload_count() {
        let config_manager = Arc::new(Mutex::new(ConfigManager::new()));
        let handler = SignalHandler::new(config_manager);

        // Note: Actual reload testing requires signal simulation
        // This test verifies the counter structure
        assert_eq!(handler.reload_count().await, 0);
    }
}
