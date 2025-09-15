# Get-UGMemberAndOwner.ps1

## Overview

The **Get-UGMemberAndOwner.ps1** script retrieves **members and owners**
of Microsoft 365 Groups (Unified Groups) and outputs the results either
to the console or to a CSV file.

This script is useful for administrators who need to audit or document
Microsoft 365 Group membership and ownership, including Teams-enabled
groups.

------------------------------------------------------------------------

## Features

- Accepts input as:
  - **Group Name (string)**
  - **UnifiedGroup object** (e.g., output from `Get-UnifiedGroup`)
- Retrieves:
  - Group Name
  - Group Email (SMTP Address)
  - Group Type (Team or Group)
  - Member Count
  - Member Details (Name, Email, Type: Member/Owner)
- Outputs results to:
  - **Console** (default)
  - **CSV file** (if `-OutCSV` parameter is specified)

------------------------------------------------------------------------

## Requirements

- Exchange Online PowerShell module with access to the following
    cmdlets:
  - `Get-UnifiedGroup`
  - `Get-UnifiedGroupLinks`
- Appropriate **Exchange Online or Microsoft 365 admin permissions**.

------------------------------------------------------------------------

## Parameters

| Parameter  | Type                       | Mandatory | Description                                                                                   |
| ---------- | -------------------------- | --------- | --------------------------------------------------------------------------------------------- |
| **Group**  | `String` or `UnifiedGroup` | Yes       | The target Microsoft 365 Group. Accepts a group name (string) or a `Get-UnifiedGroup` object. |
| **OutCSV** | `String`                   | Yes       | Full file path to export the results as a CSV file.                                           |

------------------------------------------------------------------------

## Usage Examples

### Example 1: Get group members and owners by name

``` powershell
.\Get-UGMemberAndOwner.ps1 -Group "HR Team"
```

### Example 2: Pipe UnifiedGroup object to the script

``` powershell
Get-UnifiedGroup -Identity "Finance Group" | .\Get-UGMemberAndOwner.ps1
```

### Example 3: Export results to CSV

``` powershell
.\Get-UGMemberAndOwner.ps1 -Group "IT Department" -OutCSV "C:\Reports\ITGroupMembers.csv"
```

### Example 4: Multiple groups

``` powershell
"HR Team","Finance Group" | .\Get-UGMemberAndOwner.ps1 -OutCSV "C:\Reports\Groups.csv"
```

------------------------------------------------------------------------

## Output

The script returns objects with the following properties:

| Property             | Description                                        |
| -------------------- | -------------------------------------------------- |
| **GroupName**        | Display name of the Microsoft 365 Group            |
| **GroupEmail**       | Primary SMTP address of the group                  |
| **GroupType**        | `Team` if provisioned for Teams, otherwise `Group` |
| **GroupMemberTotal** | Total number of members (including owners)         |
| **MemberName**       | Display name of the member                         |
| **MemberEmail**      | Primary SMTP address of the member                 |
| **MemberType**       | `Member` or `Owner`                                |

If exported to CSV, the file will include these same columns.

------------------------------------------------------------------------

## Error Handling

- If an invalid group is provided, the script writes an error and
    continues processing the next input.
- If CSV export fails, the script writes an error but still returns
    the result to the console.

------------------------------------------------------------------------

## Author

June Castillote
