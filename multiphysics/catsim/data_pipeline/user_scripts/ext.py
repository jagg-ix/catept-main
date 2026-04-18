import pandas as pd
import os

excel_file = "Extended_Data_Fig_3_Source_data.xlsx"
output_dir = "Extended_Fig_3_Split"

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Load workbook
xls = pd.ExcelFile(excel_file)

# Loop through each sheet
for sheet_name in xls.sheet_names:
    # Read only the current sheet
    df = pd.read_excel(xls, sheet_name=sheet_name)
    
    # Normalize column names
    df.columns = [str(col).strip().replace(" ", "_") for col in df.columns]
    
    # Create a new ExcelWriter for this sheet
    output_file = os.path.join(output_dir, f"{sheet_name.replace(' ', '_')}.xlsx")
    with pd.ExcelWriter(output_file, engine="xlsxwriter") as writer:
        # Save only this sheet into the new file
        df.to_excel(writer, sheet_name=sheet_name, index=False)
    
    print(f"Saved {output_file}")

