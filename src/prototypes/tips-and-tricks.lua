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
    trigger = {
      type = "dependencies-met"
    },
    image = "__Tapeline__/graphics/tips-and-tricks/introduction.png"
  },
  {
    type = "tips-and-tricks-item",
    name = "tl-freeform",
    category = "tapeline",
    order = "b",
    indent = 1,
    dependencies = {"tl-introduction"},
    trigger = {
      type = "build-entity",
      entity = "tl-dummy-entity",
      count = 30
    },
    image = "__Tapeline__/graphics/tips-and-tricks/freeform.png"
  }
}