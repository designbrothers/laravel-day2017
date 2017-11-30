@title[Response time]
# Enhance response time

![Response time](assets/img/4.png)
+++

##### Rules of thumb for better response time
<p class="fragment text-left text-07">Load the full dataset as needed</p>
<p class="fragment text-left text-07">Demand heavy and asyncronous task to workers</p>
<p class="fragment text-left text-07">Process data with collections and not with eloquent</p>

+++
@title[Queues]
### Queues
### Bad
```php
ExampleManager::updateStatusOnExternalService($itemId);
```
### Good
```php
dispatch(new UpdateStatusOnExternalService($item));
```
+++
@title[Eloquent eager loading]
### Eloquent eager loading
### Bad (N+1 queries)
```php
$books = App\Book::get();
foreach($books as $book){
    // Just to trigger eloquent relationship loader
    $book->author;
}
```
### Good (2 queries)
```php
$books = App\Book::with('author')->get();
foreach($books as $book){
    // Just to trigger eloquent relationship loader
    $book->author;
}
```