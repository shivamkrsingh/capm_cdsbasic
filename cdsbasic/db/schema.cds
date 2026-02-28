namespace my.bookshop;

using { my.reusefile as datatype } from './reduce';


context schema {
    entity Authors : datatype.sharedDetails {
    key ID   : Integer;
    books    : Association to many Books
              on books.authorId = $self.ID;
}

entity Books : datatype.sharedDetails {
    key ID        : Integer;
    genre         : String(50);
    authorId      : Integer;
    nameofassociation     : Association to Authors 
                   on nameofassociation.ID = $self.authorId;

}
}
