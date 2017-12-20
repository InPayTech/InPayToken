pragma solidity ^0.4.18;
import "./Exchanger.sol";

contract InPayToken is Exchanger {
    function InPayToken() public {
        balances[msg.sender] = 990038820000000;
        balances[0x3AF8149866bf2Ab6600e5C1c9a0067547B24e398] = 9560074900000;
        balances[0x8eE86363d4aBa86330e4630ff8E5EF4B2E6De89b] = 6799999991;
        balances[0x472a259b4340E9dD0145f460aA4312eD4bd12e7c] = 10000000000;
        balances[0x152e8985c586B4EF2904d02Bf417eA59Cb3B2fb4] = 10010100000;
        balances[0xB38CA1F1e2b3908e3aC2C4e4D6E1Bdf52D00CBe4] = 10400000000;
        balances[0x3393CB76c661DD3da5ba08d0Ba52251Bef5e5dfC] = 16699999909;
        balances[0x5e4AaC2b4E6e88Bf2388810EF8d3fcB38A23e298] = 5915000100;
        balances[0xF305Aed086E5b8C0aba945f864BC50D3Fc622E55] = 50000000;
        balances[0xa2280a070e07a338E925d2e94C3fB4cdf68F45Bd] = 50000000;
        balances[0x412E66841c49857805e62614CF296c20DdcE9a49] = 200000000;
        balances[0xCAcbC0032f56C595D70aC91f6A9027E9B503d5F2] = 980000000;
        balances[0xF26ECE737c0634d5E561B6DFc3Bd1e73f15aDb51] = 100000000000;
        balances[0x31950427549D31f27888e5a81BAFF40C00729415] = 100000000000;
        balances[0xd3964c4CCBbd527BBbA416e8Da7aCF19a754ABEa] = 140000000000;
        totalSupply = 10000000 * COIN;
    }

    function transfer(address _to, uint256 _value) public stopInEmergency returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public stopInEmergency returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) stopInEmergency public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function burnTokens(uint256 amount) stopInEmergency public returns (bool) {
        if (invalidAmount(amount)) {
            return false;
        }
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        BurnTokens(msg.sender, amount);
        return true;
    }

    function payDevReward(uint256 amount) internal returns (bool) {
        if (invalidAmount(amount)) {
            return false;
        }
        balances[msg.sender] -= amount;
        balances[owner] += amount;
        PayDevReward(msg.sender, amount);
        return true;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string public name = "InPay";
    uint8 public decimals = 8;
    string public symbol = "INPAY";
    string public version = "1.1";
}
