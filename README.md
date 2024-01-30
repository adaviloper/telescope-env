# telescope-env.nvim

---

Search through your projects `.env` values and quickly navigate to them.

## Intallation
Lazy
```lua
return {
  'adaviloper/telescope-env',
  config = function ()
    require('telescope').load_extension('telescope-env')
  end
}
```
