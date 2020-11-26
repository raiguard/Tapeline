data:extend{
  {
    type = "tips-and-tricks-item-category",
    name = "tapeline",
    order = "l-[tapeline]"
  },
  {
    type = "tips-and-tricks-item",
    name = "tl-introduction",
    category = "tapeline",
    order = "a",
    is_title = true,
    dependencies = {"introduction"},
    trigger = {type = "dependencies-met"},
    image = "__Tapeline__/graphics/tips-and-tricks/introduction.png"
  },
  {
    type = "tips-and-tricks-item",
    name = "tl-persistent",
    category = "tapeline",
    order = "b",
    indent = 1,
    dependencies = {"tl-introduction"},
    trigger = {type = "dependencies-met"},
    image = "__Tapeline__/graphics/tips-and-tricks/persistent.png"
  },
  {
    type = "tips-and-tricks-item",
    name = "tl-modes",
    category = "tapeline",
    order = "c",
    indent = 1,
    dependencies = {"tl-introduction"},
    trigger = {type = "dependencies-met"},
    image = "__Tapeline__/graphics/tips-and-tricks/modes.png"
  },
  {
    type = "tips-and-tricks-item",
    name = "tl-divisors",
    category = "tapeline",
    order = "d",
    indent = 1,
    dependencies = {"tl-introduction"},
    trigger = {type = "dependencies-met"},
    image = "__Tapeline__/graphics/tips-and-tricks/divisors.png"
  },
  {
    type = "tips-and-tricks-item",
    name = "tl-edit",
    category = "tapeline",
    order = "e",
    indent = 1,
    dependencies = {"tl-introduction"},
    trigger = {type = "dependencies-met"},
    image = "__Tapeline__/graphics/tips-and-tricks/edit.png"
  }
}