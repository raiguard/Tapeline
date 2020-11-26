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
    is_title = true,
    dependencies = {"introduction"},
    trigger = {
      type = "dependencies-met"
    },
    image = "__Tapeline__/graphics/tips-and-tricks/introduction.png"
  }
}