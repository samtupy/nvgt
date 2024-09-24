# remove_product
This method removes the current product.

`bool settings::remove_product();`

## Returns:
bool: true on success, false on failure

## Remarks:
This method will delete the directory of the current product if there are no other products in the company. Otherwise, the company directory will be deleted.
