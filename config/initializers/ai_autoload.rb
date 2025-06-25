# Ensure AI module is autoloaded
Rails.autoloaders.main.push_dir(Rails.root.join("app/usecases/ai")) 