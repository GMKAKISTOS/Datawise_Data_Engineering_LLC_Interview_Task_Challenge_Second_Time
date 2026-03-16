import json
import re
import uuid
import numbers
from datetime import datetime
from apex_arena._types import GradingResult

def grade(_: str) -> GradingResult:

    errors = []
    datalist = []
    schemalist = []
    schemavalidation = []

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
                        schemalist.append(s.get("schema"))
                    else:
                        #print("data = ", s.get("data"))
                        datalist.append(s.get("data"))

    except FileNotFoundError:
        return (GradingResult
        (
            score = 0.0,
            subscores = {"validation" : 0.0},
            weights = {"validation" : 1.0},
            feedback = str(len(errors)) + " validation errors"
        ))

    except json.JSONDecodeError:
        return (GradingResult
        (
            score = 0.0,
            subscores = {"validation" : 0.0},
            weights = {"validation" : 1.0},
            feedback = str(len(errors)) + " validation errors"
        ))

    for d in datalist:
        # print(d)
        for s in schemalist:
            # print(s)
            if set(d.keys()).intersection(set(s.get("properties").keys())):
                schemavalidation = s.get("properties")
                break
        if not schemavalidation:
            continue
        for r in s.get("required", []):
            # print(r)
            if r not in d:
                #print(r, " is missing in ", d, " - is invalid!")
                errors.append(str(r) + " doesn't exists in " + str(d) + " - is invalid!")
        for k in d.keys():
            # print(k)
            if k not in schemavalidation:
                if s.get("additionalProperties") is False:
                    #print("Extra field " + str(k) + " is invalid!")
                    errors.append("Extra field: " + str(k) + " is invalid!")
                    continue
        if "id" in d:
            # print(d.get("id"))
            if not (isinstance(d.get("id"), int) and d.get("id") >= 1):
                #print(d.get("id"), ": id is valid!")
            #else:
                # print(d.get("id"), ": id is invalid!")
                errors.append(str(d.get("id")) + ": id is invalid!")
        if "username" in d:
            # print(d.get("username"))
            if not (isinstance(d.get("username"), str) and 20 >= len(d.get("username")) >= 3 and re.fullmatch(
                    r'^[a-zA-Z0-9_]+$', d.get("username"))):
                #print(d.get("username"), ": username is valid!")
            #else:
                #print(d.get("username"), ": username is invalid!")
                errors.append(str(d.get("username")) + ": username is invalid!")
        if "email" in d:
            #print(d.get("email"))
            if not (isinstance(d.get("email"), str) and re.fullmatch(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+',
                                                                d.get("email"))):
                #print(d.get("email"), ": email is valid!")
            #else:
                #print(d.get("email"), ": email is invalid!")
                errors.append(str(d.get("email")) + ": email is invalid!")
        if "age" in d:
            # print(d.get("age"))
            if not (isinstance(d.get("age"), (int, float)) and (150 >= d.get("age") >= 0 or 150.0 >= d.get("age") >= 0.0)):
                #print(d.get("age"), ": age is valid!")
            #else:
                #print(d.get("age"), ": age is invalid!")
                errors.append(str(d.get("age")) + ": age is invalid!")
        if "role" in d:
            # print(d.get("role"))
            if not (isinstance(d.get("role"), str) and d.get("role") in ["admin", "user", "guest"]):
                #print(d.get("role"), ": role is valid!")
            #else:
                #print(d.get("role"), ": role is invalid!")
                errors.append(str(d.get("role")) + ": role is invalid!")
        if "sku" in d:
            #print(d.get("sku"))
            if not (isinstance(d.get("sku"), str) and re.fullmatch(r'^[A-Z]{3}-[0-9]{4}$', d.get("sku"))):
                #print(d.get("sku"), ": sku is valid!")
            #else:
                #print(d.get("sku"), ": sku is invalid!")
                errors.append(str(d.get("sku")) + ": sku is invalid!")
        if "name" in d:
            #print(d.get("name"))
            if not (isinstance(d.get("name"), str) and 100 >= len(d.get("name")) >= 1):
                #print(d.get("name"), ": name is valid!")
            #else:
                #print(d.get("name"), ": name is invalid!")
                errors.append(str(d.get("name")) + ": name is invalid!")
        if "price" in d:
            #print(d.get("price"))
            if not (isinstance(d.get("price"), numbers.Number) and (d.get("price") > 0.0 or d.get("price") > 0)):
                #print(d.get("price"), ": price is valid!")
            #else:
                #print(d.get("price"), ": price is invalid!")
                errors.append(str(d.get("price")) + ": price is invalid!")
        if "quantity" in d:
            #print(d.get("quantity"))
            if not (isinstance(d.get("quantity"), (int, float)) and (d.get("quantity") >= 0.0 or d.get("quantity") >= 0)):
                #print(d.get("quantity"), ": quantity is valid!")
            #else:
                #print(d.get("quantity"), ": quantity is invalid!")
                errors.append(str(d.get("quantity")) + ": quantity is invalid!")
        if "tags" in d:
            # print(d.get("tags"))
            if not (isinstance(d.get("tags"), list) and len(d.get("tags")) <= 5 and len(d.get("tags")) == len(
                    set(d.get("tags")))):
                #print(d.get("tags"), ": tags is valid!")
            #else:
                #print(d.get("tags"), ": tags is invalid!")
                errors.append(str(d.get("tags")) + ": tags is invalid!")
        if "active" in d:
            #print(d.get("active"))
            if not (isinstance(d.get("active"), bool)):
                #print(d.get("active"), ": active is valid!")
            #else:
                #print(d.get("active"), ": active is invalid!")
                errors.append(str(d.get("active")) + ": active is invalid!")
        if "order_id" in d:
            # print(d.get("order_id"))
            if isinstance(d.get("order_id"), str):
                try:
                    uuid.UUID(d.get("order_id"))
                    #print(d.get("order_id"), ": order_id is valid!")
                except(ValueError, TypeError):
                    #print(d.get("order_id"), ": order_id is invalid!")
                    errors.append(str(d.get("order_id")) + ": order_id is invalid!")
            else:
                #print(d.get("order_id"), ": order_id is invalid!")
                errors.append(str(d.get("order_id")) + ": order_id is invalid!")
        if "customer_email" in d:
            # print(d.get("customer_email"))
            if not (isinstance(d.get("customer_email"), str) and re.fullmatch(
                    r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+', d.get("customer_email"))):
                #print(d.get("customer_email"), ": customer_email is valid!")
            #else:
                #print(d.get("customer_email"), ": customer_email is invalid!")
                errors.append(str(d.get("customer_email")) + ": customer_email is invalid!")
        if "items" in d:
            # print(d.get("items"))
            if isinstance(d.get("items"), list) and len(d.get("items")) >= 1:
                # print(d.get("items"), ": items is valid!")
                for i in d.get("items"):
                    if not (isinstance(i.get("product_name"), str) and (isinstance(i.get("quantity"), (int, float)) and (
                            i.get("quantity") >= 1 or i.get("quantity") >= 1.0)) and (
                            isinstance(i.get("unit_price"), numbers.Number) and (
                            i.get("unit_price") >= 0 or i.get("unit_price") >= 0.0))):
                        #print(i.get("product_name"), i.get("quantity"), i.get("unit_price"), ": product_name, quantity, unit_price is valid!")
                    #else:
                        #print(i.get("product_name"), i.get("quantity"), i.get("unit_price"), ": product_name, quantity, unit_price is invalid!")
                        errors.append(str(i.get("product_name")) + " - " + str(i.get("quantity")) + " - " + str(i.get("unit_price")) + ": product_name, quantity, unit_price is invalid!")
            else:
                #print(d.get("items"), ": items is invalid!")
                errors.append(str(d.get("items")) + ": items is invalid!")
        if "total" in d:
            # print(d.get("total"))
            if not (isinstance(d.get("total"), numbers.Number) and (d.get("total") >= 0.0 or d.get("total") >= 0)):
                #print(d.get("total"), ": total is valid!")
            #else:
                #print(d.get("total"), ": total is invalid!")
                errors.append(str(d.get("total")) + ": total is invalid!")
        if "order_date" in d:
            #print(d.get("order_date"))
            if isinstance(d.get("order_date"), str):
                try:
                    datetime.strptime(d.get("order_date"), "%Y-%m-%d")
                    #print(d.get("order_date"), ": order_date is valid!")
                except(ValueError, TypeError):
                    #print(d.get("order_date"), ": order_date is invalid!")
                    errors.append(str(d.get("order_date")) + ": order_date is invalid!")
            else:
                #print(d.get("order_date"), ": order_date is invalid!")
                errors.append(str(d.get("order_date")) + ": order_date is invalid!")

    print()

    if len(errors) > 0:
        return (GradingResult
        (
            score = 0.0,
            subscores = {"validation" : 0.0},
            weights = {"validation" : 1.0},
            feedback = str(len(errors)) + " validation errors"
        ))

    return (GradingResult
        (
        score = 1.0,
        subscores = {"validation" : 1.0},
        weights = {"validation" : 1.0},
        feedback = "All validations passed"
    ))