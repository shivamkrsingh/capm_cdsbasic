using { my.bookshop.schema as datum } from '../db/schema';

service CatalogService {
    entity AuthorSet as projection on datum.Authors;
    entity BookSet as projection on datum.Books;
}