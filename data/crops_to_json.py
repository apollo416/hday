import csv
import json
import uuid
from slugify import slugify

with open("crops.csv", "r") as f:
    reader = csv.reader(f)
    next(reader)
    crops = list(reader)
    crops = [
        {
            "id": str(uuid.uuid5(namespace=uuid.NAMESPACE_DNS, name=item[0])),
            "slug": slugify(item[0]),
            "name": item[0].strip(),
            "maturation_time": int(item[1]),
            "sell_price": int(item[2]),
            "source": item[3].strip(),
            "yield": int(item[4]),
        }
        for item in crops
    ]

    with open("crops.json", "w", encoding="utf-8") as f:
        json.dump(crops, f, ensure_ascii=False, indent=4)
