## Hitchens Unordered Key Set 

[https://github.com/rob-Hitchens/UnorderedKeySet](https://github.com/rob-Hitchens/UnorderedKeySet)

Solidity Library that implements the [Solidity CRUD pattern](https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a). 

Use this library to implement Create, Retrieve, Update and Delete operations in data sets in Solidity contracts. 

### Supports logical delete

While it is true that blockchain data is immutable, there are frequently cases when a logical delete from a set is required. For example, a set of subscribers where the subscribers are transient. 

While several patterns exist (e.g. set a `bool active = false`) such structures frequently lead to the need to iterate over data and this leads to gas cost increases with scale which is unacceptable in many cases. See [Getting Loopy with Solidity](https://blog.b9lab.com/getting-loopy-with-solidity-1d51794622ad). The [Solidity CRUD pattern](https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a) is a general-purpose CRUD solution:

- Create
- Retrieve
- Update
- Delete

plus

- Count
- Iterate
- verify existance

### Scale Invariant

The operations in this pattern produce consistent gas cost *at any scale*. 

### Example Implementation

An data set with an arbitrary layout can be implemented in clean, unrepetitive code. Example, to play around in Remix:

```
pragma solidity 0.5.1;

import "./HitchensUnorderedKeySet.sol";

contract Widget {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set widgetSet;
    
    struct WidgetStruct {
        string name;
        bool delux;
        uint price;
    }
    
    mapping(bytes32 => WidgetStruct) widgets;
    
    event LogNewWidget(address sender, bytes32 key, string name, bool delux, uint price);
    event LogUpdateWidget(address sender, bytes32 key, string name, bool delux, uint price);    
    event LogRemWidget(address sender, bytes32 key);
    
    function newWidget(bytes32 key, string memory name, bool delux, uint price) public {
        widgetSet.insert(key); // Note that this will fail automatically if the key already exists.
        WidgetStruct storage w = widgets[key];
        w.name = name;
        w.delux = delux;
        w.price = price;
        emit LogNewWidget(msg.sender, key, name, delux, price);
    }
    
    function updateWidget(bytes32 key, string memory name, bool delux, uint price) public {
        require(widgetSet.exists(key), "Can't update a widget that doesn't exist.");
        WidgetStruct storage w = widgets[key];
        w.name = name;
        w.delux = delux;
        w.price = price;
        emit LogUpdateWidget(msg.sender, key, name, delux, price);
    }
    
    function remWidget(bytes32 key) public {
        widgetSet.remove(key); // Note that this will fail automatically if the key doesn't exist
        delete widgets[key];
        emit LogRemWidget(msg.sender, key);
    }
    
    function getWidget(bytes32 key) public view returns(string memory name, bool delux, uint price) {
        require(widgetSet.exists(key), "Can't get a widget that doesn't exist.");
        WidgetStruct storage w = widgets[key];
        return(w.name, w.delux, w.price);
    }
    
    function getWidgetCount() public view returns(uint count) {
        return widgetSet.count();
    }
    
    function getWidgetAtIndex(uint index) public view returns(bytes32 key) {
        return widgetSet.keyAtIndex(index);
    }
}
```

A production dapp would probably have access control for the state-changing functions. This is deliberately set aside for brevity and to show that the library is unopinionated about how that should work. For example, add `onlyOwner` modifiers to `newWidget()`, `updateWidget()` and `remWidget()` functions if appropriate.

### Motivation

The [Solidity CRUD pattern](https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a) is a reliable way of managing arbitrary data sets with transient members. However, contracts that implement multiple or nested sets tend to become cognitively heavy for developers and reviewers. 

Nesting sets can be important in cases such as [Enforcing Referential Integrity](https://medium.com/@robhitchens/enforcing-referential-integrity-in-ethereum-smart-contracts-a9ab1427ff42). 

This library separates key rules enforcement concerns from the layout of the data the application is concerned with. The result is smaller, simpler contracts that are easy to reason about. 

Example (for illustration, does not run):

```
using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
HitchensUnorderedKeySetLib.Set masterKeySet;

struct MasterThing {
  uint something;
  uint somethingElse;
  HitchensUnorderedKeySet.Set whereUsedSet;
}

mapping(bytes32 => MasterThing) masterThings;

function deleteMasterRecord(bytes32 key) public ... {
  require(masterThings[key].whereUsed.count() == 0);
  masterKeySet.remove(key);
  delete masterThings[key];
}
```

In the spirit of bumpers and guard rails, the `remove()` method requires that the key to be removed actually exists. Similarly, duplicate key inserts are prevented.

## Deployment
Load the example and the dependencies in Remix and enjoy.

Two variants:

- `...KeySet.sol` uses bytes32 keys. 
- `...AddressSet.sol` uses addresses. 

## Tests

NO TESTING OF ANY KIND HAS BEEN PERFORMED AND YOU USE THIS LIBRARY AT YOUR OWN EXCLUSIVE RISK.

## Contributors

Optimization and clean-up is ongoing.

The author welcomes pull requests, feature requests, testing assistance and feedback. Contact the author if you would like assistance with customization or calibrating the code for a specific application or gathering of different statistics.
License

## License

Copyright (c), 2019 Rob Hitchens. The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Hope it helps.
