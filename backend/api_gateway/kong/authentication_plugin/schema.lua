local typedefs = require "kong.db.schema.typedefs"

return {
  name = "custom-auth",
  fields = {
    { protocols = typedefs.protocols_http },
    { consumer = typedefs.no_consumer },
    { config = {
      type = "record",
      fields = {
        { url = typedefs.url({ required = true }) },
        {
          public_paths = {
            type = "array",
            default = {},
            required = false,
            elements = { type = "string" },
          }
        },
      },
    }, },
  },
}