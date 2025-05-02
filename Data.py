import requests
import csv
import random
import names  # Generates random first and last names
from datetime import datetime, timedelta
import pandas as pd

def convert(csv_file, xlsx_file="output.xlsx"):
    """Convert a CSV file to an XLSX file."""
    try:
        df = pd.read_csv(csv_file)
        df.to_excel(xlsx_file, index=False, engine='openpyxl')
        print(f"CSV converted to XLSX successfully! Saved as: {xlsx_file}")
    except Exception as e:
        print(f"Error: {e}")

# Fetch book data from Open Library API
url = "https://openlibrary.org/search.json?q=library&limit=20"
response = requests.get(url)
data = response.json()

# Generate CSV files for each table
def save_to_csv(filename, fieldnames, rows):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Saved {filename}!")

# Generate Author CSV
authors = {}
author_rows = []
book_rows = []

for book in data.get("docs", []):
    if "author_name" in book:
        author_name = book["author_name"][0]
        author_id = author_name.lower().replace(" ", "_")
        
        if author_id not in authors:
            first_name, last_name = author_name.split()[0], book["author_name"][0].split()[-1]
            authors[author_id] = {
                "author_id": author_id,
                "first_name": first_name,
                "last_name": last_name if first_name != last_name else "",
                "bio": "Biography not available"
            }
            author_rows.append(authors[author_id])

    book_rows.append({
        "book_id": book["key"].split("/")[-1],
        "title": book["title"],
        "author_id": author_id,
        "genre": book["subject"][0] if "subject" in book else "General"
    })

save_to_csv("author.csv", ["author_id", "first_name", "last_name", "bio"], author_rows)
save_to_csv("book.csv", ["book_id", "title", "author_id", "genre"], book_rows)

# Generate Member CSV (Random Names & Emails)
members = []
for i in range(30):
    first_name = names.get_first_name()
    last_name = names.get_last_name()
    email = f"{first_name.lower()}@gmail.com"

    members.append({
        "member_id": f"M{i+1}",
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "membership_date": (datetime.now() - timedelta(days=random.randint(100, 1000))).strftime("%Y-%m-%d")
    })

save_to_csv("member.csv", ["member_id", "first_name", "last_name", "email", "membership_date"], members)

# Generate Transaction CSV (Random)
transactions = []
for i in range(30):
    book = random.choice(book_rows)
    member = random.choice(members)
    checkout_date = datetime.now() - timedelta(days=random.randint(1, 30))
    due_date = checkout_date + timedelta(days=14)
    return_date = due_date + timedelta(days=random.choice([0, 3, 7, -2, -1]))

    transactions.append({
        "transaction_id": f"T{i+1}",
        "book_id": book["book_id"],
        "member_id": member["member_id"],
        "checkout_date": checkout_date.strftime("%Y-%m-%d"),
        "due_date": due_date.strftime("%Y-%m-%d"),
        "return_date": return_date.strftime("%Y-%m-%d") if random.choice([True, False]) else ""
    })

save_to_csv("transaction.csv", ["transaction_id", "book_id", "member_id", "checkout_date", "due_date", "return_date"], transactions)

# Generate Fine CSV (Random)
fine_rows = []
for transaction in transactions:
    if transaction["return_date"] and datetime.strptime(transaction["return_date"], "%Y-%m-%d") > datetime.strptime(transaction["due_date"], "%Y-%m-%d"):
        fine_rows.append({
            "fine_id": f"F{len(fine_rows)+1}",
            "transaction_id": transaction["transaction_id"],
            "amount": round(random.uniform(5, 20), 2),
            "is_payed": random.choice(["Yes", "No"])
        })

save_to_csv("fine.csv", ["fine_id", "transaction_id", "amount", "is_payed"], fine_rows)

# Generate Staff CSV (Random)
staff_rows = []
for i in range(10):
    first_name = names.get_first_name()
    last_name = names.get_last_name()
    email = f"{first_name.lower()}@gmail.com"

    staff_rows.append({
        "staff_id": f"S{i+1}",
        "name": f"{first_name} {last_name}",
        "email": email,
        "role": random.choice(["Librarian", "Assistant", "Manager"]),
        "hire_date": (datetime.now() - timedelta(days=random.randint(500, 5000))).strftime("%Y-%m-%d")
    })

save_to_csv("staff.csv", ["staff_id", "name", "email", "role", "hire_date"], staff_rows)

convert("book.csv","book.xlsx")
convert("member.csv","member.xlsx")
convert("author.csv","author.xlsx")
convert("fine.csv","fine.xlsx")
convert("staff.csv","staff.xlsx")
convert("transaction.csv","transaction.xlsx")

