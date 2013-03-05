if not $ or not shdr or not shdr.App
  console.warn "Unable to start Shdr, please load required libraries first."
else
  $(=> @app = new shdr.App("editor", "viewer"))