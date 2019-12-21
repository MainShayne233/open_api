file = File.read!("tax_jar.json")
spec = Jason.decode!(file)
