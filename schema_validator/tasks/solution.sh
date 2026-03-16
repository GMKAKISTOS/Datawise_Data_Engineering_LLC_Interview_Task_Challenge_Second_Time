#!/bin/bash
set -euo pipefail
python3 << 'PY'
import json
import re
import uuid
import numbers
from datetime import datetime
from pathlib import Path

def error_format1(document_id, schema_id, valid):
    return{
        "document_id": document_id,
        "schema_id": schema_id,
        "valid": valid
    }

def error_format(document_id, schema_id, valid, path, message, constraint, expected, actual):
    return [
        error_format1(document_id, schema_id, valid),
        {
        "errors":
        [{
        "path": path,
        "message": message,
        "constraint": constraint,
        "expected": expected,
        "actual": actual
        }]
        }
           ]


def validate_all(schemalist, datalist):

    return_data = []
    schemavalidation = []

    for d in datalist:
        #print(d)
        for s in schemalist:
            #print(s)
            if set(d.keys()).intersection(set(s.get("properties").keys())):
                schemavalidation = s.get("properties")
                break
        if not schemavalidation:
            continue
        errors = []
        for r in s.get("required", []):
            #print(r)
            if r in ("document_id", "schema_id"):
                continue
            if r not in d:
                print(r, "is missing in ", d, " - is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$." + str(r), "Required field " + str(r) + " is missing", "required", "field " + str(r) + " to be present", "field absent"))
        for k in d.keys():
            #print(k)
            if k in ("document_id", "schema_id"):
                continue
            if k not in schemavalidation:
                if s.get("additionalProperties") is False:
                    print("Extra field " + str(k) + " is invalid!")
                    errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$." + str(k), "Additional property " +  str(k) + " is not allowed", "additionalProperties", "no extra fields", str(k)))
                continue
        if "id" in d:
            #print(d.get("id"))
            if isinstance(d.get("id"), int) and d.get("id") >= 1:
                print(d.get("id"), ": id is valid!")
            else:
                #print(d.get("id"), ": id is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.id", "id must be a positive integer", "minimum", "integer >= 1", str(d.get("id"))))
        if "username" in d:
            #print(d.get("username"))
            if isinstance(d.get("username"), str) and 20 >= len(d.get("username")) >= 3 and re.fullmatch(r'^[a-zA-Z0-9_]+$', d.get("username")):
                print(d.get("username"), ": username is valid!")
            else:
                print(d.get("username"), ": username is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.username", "username must be 3-20 alphanumeric/underscore characters", "pattern", "3-20 chars, [a-zA-Z0-9_]", str(d.get("username"))))
        if "email" in d:
            #print(d.get("email"))
            if isinstance(d.get("email"), str) and re.fullmatch(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+', d.get("email")):
                print(d.get("email"), ": email is valid!")
            else:
                print(d.get("email"), ": email is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.email", "Invalid email format", "format", "email", str(d.get("email"))))
        if "age" in d:
            #print(d.get("age"))
            if isinstance(d.get("age"), (int, float)) and (150 >= d.get("age") >= 0 or 150.0 >= d.get("age") >= 0.0):
                print(d.get("age"), ": age is valid!")
            else:
                print(d.get("age"), ": age is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.age", "age must be an integer between 0 and 150", "minimum", "0 <= age <= 150", str(d.get("age"))))
        if "role" in d:
            #print(d.get("role"))
            if isinstance(d.get("role"), str) and d.get("role") in ["admin", "user", "guest"]:
                print(d.get("role"), ": role is valid!")
            else:
                print(d.get("role"), ": role is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.role", "role must be one of: admin, user, guest", "enum", "admin | user | guest", str(d.get("role"))))
        if "sku" in d:
            #print(d.get("sku"))
            if isinstance(d.get("sku"), str) and re.fullmatch(r'^[A-Z]{3}-[0-9]{4}$', d.get("sku")):
                print(d.get("sku"), ": sku is valid!")
            else:
                print(d.get("sku"), ": sku is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.sku", "sku must match pattern XXX-0000", "pattern", "^[A-Z]{3}-[0-9]{4}$", str(d.get("sku"))))
        if "name" in d:
            #print(d.get("name"))
            if isinstance(d.get("name"), str) and 100 >= len(d.get("name")) >= 1:
                print(d.get("name"), ": name is valid!")
            else:
                print(d.get("name"), ": name is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.name", "name must be a string of 1-100 characters", "type", "string, length 1-100", str(d.get("name"))))
        if "price" in d:
            #print(d.get("price"))
            if isinstance(d.get("price"), numbers.Number) and (d.get("price") > 0.0 or d.get("price") > 0):
                print(d.get("price"), ": price is valid!")
            else:
                print(d.get("price"), ": price is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.price", "price must be a positive number", "minimum", "> 0", str(d.get("price"))))
        if "quantity" in d:
            #print(d.get("quantity"))
            if isinstance(d.get("quantity"), (int, float)) and (d.get("quantity") >= 0.0 or d.get("quantity") >= 0):
                print(d.get("quantity"), ": quantity is valid!")
            else:
                print(d.get("quantity"), ": quantity is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.quantity", "quantity must be an integer >= 0", "minimum", ">= 0", str(d.get("quantity"))))
        if "tags" in d:
            #print(d.get("tags"))
            if isinstance(d.get("tags"), list) and len(d.get("tags")) <= 5 and len(d.get("tags")) == len(set(d.get("tags"))):
                print(d.get("tags"), ": tags is valid!")
            else:
                print(d.get("tags"), ": tags is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.tags", "tags must be a list of up to 5 unique values", "uniqueItems", "list, max 5, no duplicates", str(d.get("tags"))))
        if "active" in d:
            #print(d.get("active"))
            if isinstance(d.get("active"), bool):
                print(d.get("active"), ": active is valid!")
            else:
                print(d.get("active"), ": active is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.active", "active must be a boolean", "type", "boolean", str(d.get("active"))))
        if "order_id" in d:
            #print(d.get("order_id"))
            if isinstance(d.get("order_id"), str):
                try:
                    uuid.UUID(d.get("order_id"))
                    print(d.get("order_id"), ": order_id is valid!")
                except(ValueError, TypeError):
                    print(d.get("order_id"), ": order_id is invalid!")
                    errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.order_id", "order_id must be a valid UUID string", "format", "UUID v4", str(d.get("order_id"))))
            else:
                print(d.get("order_id"), ": order_id is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.order_id", "order_id must be a valid UUID string", "format", "UUID v4", str(d.get("order_id"))))
        if "customer_email" in d:
            #print(d.get("customer_email"))
            if isinstance(d.get("customer_email"), str) and re.fullmatch(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+', d.get("customer_email")):
                print(d.get("customer_email"), ": customer_email is valid!")
            else:
                print(d.get("customer_email"), ": customer_email is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.customer_email", "Invalid customer_email format", "format", "email", str(d.get("customer_email"))))
        if "items" in d:
            #print(d.get("items"))
            if isinstance(d.get("items"), list) and len(d.get("items")) >= 1:
                #print(d.get("items"), ": items is valid!")
                for i in d.get("items"):
                    if isinstance(i.get("product_name"), str) and (isinstance(i.get("quantity"), (int, float)) and (i.get("quantity") >= 1 or i.get("quantity") >= 1.0)) and (isinstance(i.get("unit_price"), numbers.Number) and (i.get("unit_price") >= 0 or i.get("unit_price") >= 0.0)):
                        print(i.get("product_name"), i.get("quantity"), i.get("unit_price"), ": product_name, quantity, unit_price is valid!")
                    else:
                        print(i.get("product_name"), i.get("quantity"), i.get("unit_price"), ": product_name, quantity, unit_price is invalid!")
                        errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.items", "product_name must be a string, quantity must be >= 1, (unit_price must be >= 0 or >= 0.0)", "minimum", "product_name must be a string, quantity must be >= 1, (unit_price must be >= 0 or >= 0.0)", str(i)))
            else:
                print(d.get("items"), ": items is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.items", "items must be a non-empty list", "minimum", "list with >= 1 item", str(d.get("items"))))
        if "total" in d:
            #print(d.get("total"))
            if isinstance(d.get("total"), numbers.Number) and (d.get("total") >= 0.0 or d.get("total") >= 0):
                print(d.get("total"), ": total is valid!")
            else:
                print(d.get("total"), ": total is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.total", "total must be a number >= 0", "minimum", ">= 0", str(d.get("total"))))
        if "order_date" in d:
            #print(d.get("order_date"))
            if isinstance(d.get("order_date"), str):
                try:
                    datetime.strptime(d.get("order_date"), "%Y-%m-%d")
                    print(d.get("order_date"), ": order_date is valid!")
                except(ValueError, TypeError):
                    print(d.get("order_date"), ": order_date is invalid!")
                    errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.order_date", "order_date must be a string in YYYY-MM-DD format", "format", "YYYY-MM-DD", str(d.get("order_date"))))
            else:
                print(d.get("order_date"), ": order_date is invalid!")
                errors.extend(error_format(str(d.get("document_id")), str(s.get("schema_id")), False, "$.order_date", "order_date must be a string in YYYY-MM-DD format", "format", "YYYY-MM-DD", str(d.get("order_date"))))

        if errors:
            return_data.extend(errors)
        else:
            return_data.extend([error_format1(str(d.get("document_id")), str(s.get("schema_id")), True), {"errors": []}])

    print()

    return return_data

def main():

    schemalist = []
    datalist = []

    try:
        with open('/workdir/data/validation_request.json', 'r') as file:
            data = json.load(file)
            #print("File data = ", data)
            print()
            for d in data.values():
                #print(d)
                for s in d:
                    if s.get("schema"):
                        #print("schema = ", s.get("schema"))
                        s.get("schema")["schema_id"] = s.get("schema_id")
                        schemalist.append(s.get("schema"))
                    else:
                        #print("data = ", s.get("data"))
                        s.get("data")["document_id"] = s.get("document_id")
                        datalist.append(s.get("data"))

            results = validate_all(schemalist, datalist)

            errors = {}

            total_errors = 0
            total_documents = 0
            valid_documents = 0
            invalid_documents = 0
            no_duplicate_documents = []

            for error in results:
                if "valid" in error:
                    document_id = error.get("document_id")
                    if document_id not in no_duplicate_documents:
                        no_duplicate_documents.append(document_id)
                        total_documents = total_documents + 1
                        if error.get("valid"):
                            valid_documents = valid_documents + 1
                        else:
                            invalid_documents = invalid_documents + 1

                errors_list = error.get("errors", [])
                if errors_list:
                    get_message_from_constraint = errors_list[0].get("constraint")
                    if get_message_from_constraint:
                        errors[get_message_from_constraint] = errors.get(get_message_from_constraint, 0) + 1
                        total_errors = total_errors + 1

            output = {
            "validation_results": results,
            "summary": {
            "total_documents": total_documents,
            "valid_documents": valid_documents,
            "invalid_documents": invalid_documents,
            "total_errors": total_errors,
            "errors": errors
            }
            }

            print(json.dumps(output, indent = 2))

            with open('/workdir/validation_results.json', 'w') as file2:
                json.dump(output, file2, indent = 2)

    except FileNotFoundError:
        print("\nError: the file 'validation_request.json' was not found.\n")
        results = []

    except json.JSONDecodeError:
        print("\nError: failed to decode json from the file.\n")
        results = []

if __name__ == "__main__":
    main()
PY
