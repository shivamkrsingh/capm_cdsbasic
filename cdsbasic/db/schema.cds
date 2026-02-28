namespace my.bookshop;
context schema {
    entity Authors {
    key ID   : UUID;
    name     : String(100);
    country  : String(50);
}

entity Books {
    key ID        : UUID;
    title         : String(100);
    genre         : String(50);
    author       : Association to Authors; 
}
}
