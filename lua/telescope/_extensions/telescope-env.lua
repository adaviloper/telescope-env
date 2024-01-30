return require('telescope').register_extension({
  setup = function(ext_config, config)
    --
  end,
  exports = {
    env_values = require('telescope-env').env_values
  }
})
