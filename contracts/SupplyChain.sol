pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
    address public owner;

    uint public skuCount;

    mapping(uint => Item) public items;

    enum State {
        ForSale,
        Sold,
        Shipped,
        Received
    }

    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    event LogForSale(uint sku);
    event LogSold(uint sku);
    event LogShipped(uint sku);
    event LogReceived(uint sku);

    modifier isOwner() {
        require(msg.sender == owner, "Must be the owner to call this function");
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "Unrecognized caller");
        _;
    }

    modifier paidEnough(uint _price) {
        require(msg.value >= _price, "Insufficient payment");
        _;
    }

    modifier checkValue(uint _sku) {
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
        _;
    }

    modifier forSale(uint _sku) {
        require(items[_sku].state == State.ForSale && items[_sku].price > 0);
        _;
    }
    modifier sold(uint _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }
    modifier shipped(uint _sku) {
        require(items[_sku].state == State.Shipped);
        _;
    }
    modifier received(uint _sku) {
        require(items[_sku].state == State.Received);
        _;
    }

    constructor() public {
        owner = msg.sender;

        skuCount = 0;
    }

    function addItem(string memory _name, uint _price)
        public
        returns (bool)
    {
        emit LogForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });
        skuCount = skuCount + 1;
        return true;
    }

    function buyItem(uint _sku)
        public
        payable
        forSale(_sku)
        paidEnough(_sku)
        checkValue(_sku)
    {
        emit LogSold(_sku);
        items[_sku].buyer = msg.sender;
        items[_sku].seller.transfer(items[_sku].price);
        items[_sku].state = State.Sold;
    }

    function shipItem(uint sku)
        public
        sold(sku)
        verifyCaller(items[sku].seller)
    {
        items[sku].state = State.Shipped;
        emit LogShipped(sku);
    }

    function receiveItem(uint sku)
        public
        shipped(sku)
        verifyCaller(items[sku].buyer)
    {
        items[sku].state = State.Received;
        emit LogReceived(sku);
    }

    function fetchItem(uint _sku)
        public
        view
        returns (
            string memory name,
            uint sku,
            uint price,
            uint state,
            address seller,
            address buyer
        )
    {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }
}
