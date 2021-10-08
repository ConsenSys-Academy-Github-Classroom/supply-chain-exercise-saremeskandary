// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
    // <owner>
    address public owner = msg.sender;
    // <skuCount>
    uint public skuCount = 0;
    // <items mapping>
    mapping(address => uint256) internal items;

    // <enum State: ForSale, Sold, Shipped, Received>
    enum State {
        ForSale,
        Sold,
        Shipped,
        Received
    }

    // <struct Item: name, sku, price, state, seller, and buyer>
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address seller;
        address buyer;
    }

    /*
     * Events
     */

    // <LogForSale event: sku arg>
    event LogForSale(int256 sku);
    // <LogSold event: sku arg>
    event LogSold(int256 sku);
    // <LogShipped event: sku arg>
    event LogShipped(int256 sku);
    // <LogReceived event: sku arg>
    event LogReceived(int256 sku);
    /*
     * Modifiers
     */

    // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    // <modifier: isOwner

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    // modifier checkValue(uint256 _sku) {
    //     // refund them after pay for item (why it is before, _ checks for logic before func)
    //     uint _price = items[_sku].price;
    //     uint amountToRefund = msg.value - _price;
    //     items[_sku].buyer.transfer(amountToRefund);
    //     _;
    // }

    // the forSale modifier should
    // require that the item with the given sku has the state ForSale. Note that
    // the uninitialized Item.State is 0, which is also the index of the ForSale
    // value, so checking that Item.State == ForSale is not sufficient to check
    // that an Item is for sale. Hint: What item properties will be non-zero when
    // an Item has been added?

    // modifier forSale() {
    //     require(State.ForSale == true);
    //     _;
    // }
    // modifier sold(uint256 _sku) {
    // 	require(Item[_sku].itemState == State.Sold);
    //     _;
    // }
    // modifier shipped(uint _sku) {
    // 	require(State.Shipped == true);
    //     _;
    // }
    // modifier received(uint _sku) {
    // 	require(State.Received == true);
    //     _;
    // }

    constructor(address _owner, uint _skuCount) public {
        // 1. Set the owner to the transaction sender
        owner = _owner;
        // 2. Initialize the sku count to 0. Question, is this necessary? no
        skuCount = _skuCount;
    }

    function addItem(string memory _name, uint _price)
        public
        returns (bool)
    {
        // 1. Create a new item and put in array
        items[msg.sender] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });
        // 2. Increment the skuCount by one
        skuCount += 1;
        // 3. Emit the appropriate event
        emit LogForSale(skuCount);
        // 4. return true
        return true;
    }

    // Implement this buyItem function.
    // 1. it should be payable in order to receive refunds
    // 2. this should transfer money to the seller,
    // 3. set the buyer as the person who called this transaction,
    // 4. set the state to Sold.
    // 5. this function should use 3 modifiers to check
    //    - if the item is for sale,
    //    - if the buyer paid enough,
    //    - check the value after the function is called to make
    //      sure the buyer is refunded any excess ether sent.
    // 6. call the event associated with this function!
    function buyItem(uint256 sku) public payable {}

    // 1. Add modifiers to check:
    //    - the item is sold already
    //    - the person calling this function is the seller.
    // 2. Change the state of the item to shipped.
    // 3. call the event associated with this function!
    function shipItem(uint256 sku) public {}

    // 1. Add modifiers to check
    //    - the item is shipped already
    //    - the person calling this function is the buyer.
    // 2. Change the state of the item to received.
    // 3. Call the event associated with this function!
    function receiveItem(uint256 sku) public {}

    // Uncomment the following code block. it is needed to run tests
    /* function fetchItem(uint _sku) public view */
    /*   returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) */
    /* { */
    /*   name = items[_sku].name; */
    /*   sku = items[_sku].sku; */
    /*   price = items[_sku].price; */
    /*   state = uint(items[_sku].state); */
    /*   seller = items[_sku].seller; */
    /*   buyer = items[_sku].buyer; */
    /*   return (name, sku, price, state, seller, buyer); */
    /* } */
}
