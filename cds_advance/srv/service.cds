using { extreme as db } from '../db/schema';

service RealtimeService {

    @odata.draft.enabled
    entity SalesOrders as projection on db.SalesOrder;

    @cds.redirection.target
    entity SalesOrderItems as projection on db.SalesOrderItem;

    entity Products as projection on db.Product;
    entity Categories as projection on db.Category;
    entity BusinessPartners as projection on db.BusinessPartner;
    entity Addresses as projection on db.Address;
    entity SalesAnalytics as projection on db.SalesAnalytics;
}

annotate RealtimeService.SalesOrders with @(
    UI.HeaderInfo : {
        TypeName: 'Sales Order',
        TypeNamePlural: 'Sales Orders',
        Title: { Value: orderNo }
    },
    UI.LineItem : [
        { Value: orderNo },
        { Value: totalAmount },
        { Value: currency },
        { Value: status }
    ]
);