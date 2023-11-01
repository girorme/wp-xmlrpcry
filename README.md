![WordPress Logo](assets/wp-logo.png)

# WP-XMLRPCry

WP-XMLRPCry is a powerful WordPress XML-RPC brute-force tool. It's designed to test the security of WordPress websites by attempting to log in with a list of usernames and passwords.

### Compilation

Requirements:
- Elixir > 1.13

To compile the tool, run the following command:

> mix escript.build

This command generates a binary executable inside the bin/ folder.

### How to Use
You can use WP-XMLRPCry with various options to perform a WordPress XML-RPC brute-force attack. Here are the available options:

```
Usage:
  wp_xmlrpcry [options]

Example:
  wp_xmlrpcry -u url_list.txt --users users.txt -w wordlist.txt -c workers_qty -o output

Options:
  -h  --help           Print help message
  -u  --url-list       File containing a list of URLs
  --users              File containing a list of usernames
  -w  --wordlist       File containing one password per line
  -c  --concurrency    Number of workers to spawn (default: 1)
  -o  --output         File to write the results
```

### Disclaimer
Please use this tool responsibly and ethically to test the security of your WordPress websites or for any other legitimate purposes. Unauthorized brute-force attacks may be illegal and violate the terms of service of many websites.