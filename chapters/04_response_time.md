@title[Response time]
# Enhance response time

![Happy developer](assets/img/4.png)
+++

##### Rules of thumb for better response time
<p class="fragment text-left text-07">Load the full dataset as needed</p>
<p class="fragment text-left text-07">Demand heavy and asyncronous task to workers</p>

+++
@title[Queues]
### Queues

```php
namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;

class MyJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $payload;

    public function __construct($payload)
    {
        $this->payload = $payload;
    }

    public function handle($processor)
    {
        sleep(1000)
    }
}

dispatch(new MyJob);
```
+++

@title[Eloquent eager loading]
### Eloquent eager loading

N+1 => 2

```php
$books = App\Book::with('author')->get();
```