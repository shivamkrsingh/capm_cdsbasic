namespace my.bookshop;
context schema {
    entity Authors {
    key ID   : Integer;
    name     : String(100);
    country  : String(50);
    books    : Association to many Books
              on books.authorId = $self.ID;
}

entity Books {
    key ID        : Integer;
    title         : String(100);
    genre         : String(50);
    authorId      : Integer;
    nameofassociation     : Association to Authors 
                   on nameofassociation.ID = $self.authorId;

}
}
