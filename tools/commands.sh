#!/bin/bash

# node tools/generate-object.js \
#     --name User \
#     --field @tempUserId:string:TEMP_USER_ID_LENGTH \
#     --field @emailAddress:string:EMAIL_ADDRESS_LENGTH \
#     --field =passwordHash:string:PASSWORD_HASH_LENGTH \
#     --field =passwordSalt:string:PASSWORD_SALT_LENGTH \
#     --field isAdmin:boolean=false \
#     --field emailConfirmed:boolean=false

# node tools/generate-object.js \
#     --name UserToken \
#     --field @*userId:integer \
#     --field @key:string:KEY_LENGTH \
#     --field enabled:boolean=true \
#     --field used:boolean=false \
#     --field =type:string:TYPE_LENGTH \
#     --field =singleUse:boolean

# node tools/generate-object.js \
#     --name UserFact \
#     --field @*userId:integer \
#     --field ~key:USER_FACT:KEY_LENGTH \
#     --field =secKey:string:BLOB_LENGTH \
#     --field ~value:string:VALUE_LENGTH \
#     --field =secValue:string:BLOB_LENGTH \
#     --field =secure:boolean

# node tools/generate-object.js \
#     --name UserLineItem \
#     --field =idx:integer \
#     --field @*userId:integer \
#     --field =attributes:string=empty:BLOB_LENGTH \
#     --field =lastEditedAt:Date=getNow\(\) \
#     --field ~history:Array\<UserLineItemHistory\>=[]

# node tools/generate-object.js \
#     --name UserLineItemSet \
#     --field @*userId:integer \
#     --field =title:string:TITLE_LENGTH

# node tools/generate-object.js \
#     --name Account \
#     --field @*userId:integer \
#     --field =type:ACCOUNT_TYPE:TYPE_LENGTH \
#     --field =description:string:DESCRIPTION_LENGTH

# node tools/generate-object.js \
#     --name Transaction \
#     --field @*accountId:integer \
#     --field =type:TRANSACTION_TYPE:TYPE_LENGTH \
#     --field =date:Date \
#     --field ~name:string=undefined:NAME_LENGTH \
#     --field =secName:string:BLOB_LENGTH \
#     --field ~description:string=undefined:DESCRIPTION_LENGTH \
#     --field =secDescription:string:BLOB_LENGTH \
#     --field ~category:string=undefined:CATEGORY_LENGTH \
#     --field =secCategory:string:BLOB_LENGTH \
#     --field ~amount:double=undefined \
#     --field =secAmount:string:BLOB_LENGTH

# node tools/generate-object.js \
#     --name Household \
#     --field @*userId:integer

# node tools/generate-object.js \
#     --name HouseholdMember \
#     --field @*householdId:integer \
#     --field =type:HOUSEHOLD_MEMBER_TYPE:TYPE_LENGTH

# node tools/generate-object.js \
#     --name HouseholdMemberFact \
#     --field @*householdMemberId:integer \
#     --field ~key:HOUSEHOLD_MEMBER_FACT:KEY_LENGTH \
#     --field =secKey:string:BLOB_LENGTH \
#     --field ~value:string:VALUE_LENGTH \
#     --field =secValue:string:BLOB_LENGTH \
#     --field =secure:boolean

# node tools/generate-store.js \
#     --name KeyboardEvent

# node tools/generate-component.js \
#     --name "BudgetSection" \
#     --shared

# node tools/generate-object.js \
#     --name Modal \
#     --shared \
#     --field =title:string \
#     --field =message:string \
#     --field =primaryButtonText:string \
#     --field =primaryButtonStyle:string \
#     --field =primaryButtonClick:"()=>any" \
#     --field =secondaryButtonText:string \
#     --field =secondaryButtonStyle:string \
#     --field =secondaryButtonClick:"()=>any"

# node tools/generate-object.js \
#     --name Scenario \
#     --field @*userId:integer \
#     --field =title:string

# node tools/generate-component.js \
#     --name "Scenarios"

# node tools/generate-service.js \
#     --name "Scenario"

# node tools/generate-store.js \
#     --name "Error"

# node tools/generate-object.js \
#     --name UserLineItem \
#     --field =idx:integer \
#     --field @*userId:integer \
#     --field !@*setId:integer \
#     --field !@*scenarioId:integer \
#     --field !@*scenarioForLineItemId:integer \
#     --field ~scenarios:Array\<UserLineItem\>=[] \
#     --field !@*historyForLineItemId:integer \
#     --field ~history:Array\<UserLineItem\>=[] \
#     --field =group:LINE_ITEM_GROUP_TYPE:GROUP_LENGTH \
#     --field =type:LINE_ITEM_ASSET_TYPE\|LINE_ITEM_LIABILITY_TYPE\|LINE_ITEM_INCOME_TYPE\|LINE_ITEM_EXPENSE_TYPE:TYPE_LENGTH \
#     --field =secExtraInfo:string=empty:BLOB_LENGTH \
#     --field =lastEditedAt:Date=getNow\(\)

# node tools/generate-object.js \
#     --name UserHousehold \
#     --field @*userId:integer \
#     --field @*householdId:integer \
#     --field =isEnabled:boolean

# node tools/generate-component.js \
#     --name "Subscribe"

# node tools/generate-component.js \
#     --shared \
#     --name "TransactionsImport"

# node tools/generate-attribute.js \
#     --name "Share" \
#     --type "string"

# node tools/generate-object.js \
#     --name BankStatement \
#     --field @*userId:integer \
#     --field @*householdId:integer