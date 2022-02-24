pragma solidity 0.8.10;

interface IERC20 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function approve(address _spender, uint256 _amount) external;
}

interface ISwapper {
    struct OrderIn {
        address tokenIn;
        uint96 expiryCheckpoint;
        uint256 tokensIn;
        uint256 tokensOut;
        address tokenOut;
    }
}

contract Swapper is ISwapper {
    uint256 public orderCounter = 1;
    struct TokenOrder {
        address tokenIn;
        uint96 expiryCheckpoint;
        uint256 totalTokenIn;
        uint256 totalTokenOut;
        address tokenOut;
        bool fulfilled;
        address owner;
        uint256 totalTokensBought;
    }
    mapping(uint256 => TokenOrder) private allOrders;

    event orderPlaced(
        address tokenIn,
        uint96 expiryCheckpoint,
        uint256 tokensIn,
        uint256 tokensOut,
        address tokenOut
    );
    event orderExecuted(
        uint256 indexed orderId,
        uint256 amountBought,
        uint256 amountRemaining,
        address indexed to
    );

    function placeOrder(OrderIn calldata _in) external returns (uint256 no_) {
        TokenOrder storage t = allOrders[orderCounter];
        t.tokenIn = _in.tokenIn;
        require((block.timestamp + 1e4) < _in.expiryCheckpoint, "time too low");
        t.expiryCheckpoint = _in.expiryCheckpoint;
        require(
            IERC20(_in.tokenIn).transferFrom(
                msg.sender,
                address(this),
                _in.tokensIn
            )
        );
        t.tokenOut = _in.tokenOut;
        t.tokenIn = _in.tokenIn;
        t.totalTokenIn = _in.tokensIn;
        t.totalTokenOut = _in.tokensOut;
        t.owner = msg.sender;
        emit orderPlaced(
            _in.tokenOut,
            t.expiryCheckpoint,
            _in.tokensIn,
            _in.tokensOut,
            _in.tokenOut
        );
        orderCounter++;
        return orderCounter - 1;
    }

    function getOutPrice(uint256 _orderNo)
        public
        view
        returns (uint256 price_)
    {
        TokenOrder memory t = allOrders[_orderNo];
        assert(t.owner != address(0));
        price_ = ((t.totalTokenOut * 1e5) / t.totalTokenIn);
    }

    function fulfillOrder(uint256 _orderNo, uint256 _toBuy) external {
        TokenOrder storage t = allOrders[_orderNo];
        assert(t.owner != address(0));
        assert(_toBuy <= (t.totalTokenIn - t.totalTokensBought));
        assert(t.expiryCheckpoint > block.timestamp);
        uint256 toPay = (getOutPrice(_orderNo) * _toBuy) / 1e5;
        require(IERC20(t.tokenOut).transferFrom(msg.sender, t.owner, toPay));
        require(IERC20(t.tokenIn).transfer(msg.sender, _toBuy));
        t.totalTokensBought += _toBuy;
        t.fulfilled = (t.totalTokenIn - t.totalTokensBought) < 1 ? true : false;
        emit orderExecuted(
            _orderNo,
            _toBuy,
            t.totalTokenIn - t.totalTokensBought,
            msg.sender
        );
    }

    function checkOrder(uint256 _orderNo)
        external
        view
        returns (TokenOrder memory)
    {
        assert(allOrders[_orderNo].owner != address(0));
        return allOrders[_orderNo];
    }
}
