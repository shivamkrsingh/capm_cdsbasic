namespace extreme;

using { cuid, managed } from '@sap/cds/common';

/* =========================
   Reusable Types + Regex
========================= */

type PhoneNumber : String(15)
    @assert.format: '^\+?[1-9]\d{1,14}$';

type MobileNumber : String(15)
    @assert.format: '^\+?[6-9]\d{9}$';

type CurrencyCode : String(3);

type Amount : Decimal(15,2);

type Status : String enum {
    OPEN;
    CLOSED;
    CANCELLED;
}

/* =========================
   Currency Aspect
========================= */

aspect CurrencyAspect {
    amount   : Amount;
    currency : CurrencyCode;
}

/* =========================
   Category
========================= */

entity Category : cuid, managed {
    name : localized String(100);
    products : Association to many Product
        on products.category = $self;
}

/* =========================
   Product (Localized)
========================= */

entity Product : cuid, managed {
    name        : localized String(200);
    description : localized String(500);

    price       : Amount;
    currency    : CurrencyCode;

    stock       : Integer;

    category    : Association to Category;
}

/* =========================
   Business Partner
========================= */

entity BusinessPartner : cuid, managed {
    name     : String(150);
    phone    : PhoneNumber;
    mobile   : MobileNumber;

    addresses : Association to many Address
        on addresses.partner = $self;
}

/* =========================
   Address (Bidirectional)
========================= */

entity Address : cuid, managed {
    street  : String(200);
    city    : String(100);
    country : String(50);

    partner : Association to BusinessPartner;
}

/* =========================
   Sales Order (Draft Ready)
========================= */

entity SalesOrder : cuid, managed {
    orderNo  : String(20);
    status   : Status;

    partner  : Association to BusinessPartner;

    items    : Composition of many SalesOrderItem
               on items.parent = $self;

    totalAmount : Amount;
    currency    : CurrencyCode;
}

/* =========================
   Sales Order Item
========================= */

entity SalesOrderItem : cuid, managed {
    parent   : Association to SalesOrder;
    product  : Association to Product;

    quantity : Integer;
    price    : Amount;
    currency : CurrencyCode;
}

/* =========================
   Currency Rate
========================= */

entity CurrencyRate : cuid {
    sourceCurrency : CurrencyCode;
    targetCurrency : CurrencyCode;
    rate           : Decimal(15,6);
}


@readonly
@Analytics.dataCategory: #CUBE
entity SalesAnalytics
    as select from SalesOrderItem
{
    key parent.orderNo as OrderNo : String(20),
    key currency                  : CurrencyCode,
    sum(price * quantity)          as Revenue : Decimal(15,2)
}
group by parent.orderNo, currency;