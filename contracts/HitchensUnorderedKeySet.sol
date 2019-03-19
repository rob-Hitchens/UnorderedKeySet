pragma solidity 0.5.1; 

import "./Ownable.sol";

library HitchensUnorderedKeySetLib {
    
    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }
    
    function insert(Set storage self, bytes32 key) internal {
        require(!exists(self, key), "UnorderedKeySet(501) - Key already exists in the set.");
        self.keyPointers[key] = self.keyList.push(key)-1;
    }
    
    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "UnorderedKeySet(502) - Key does not exist in the set.");
        bytes32 keyToMove = self.keyList[count(self)-1];
        uint rowToReplace = self.keyPointers[key];
        self.keyPointers[keyToMove] = rowToReplace;
        self.keyList[rowToReplace] = keyToMove;
        delete self.keyPointers[key];
        self.keyList.length--;
    }
    
    function count(Set storage self) public view returns(uint) {
        return(self.keyList.length);
    }
    
    function exists(Set storage self, bytes32 key) public view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }
    
    function keyAtIndex(Set storage self, uint index) public view returns(bytes32) {
        return self.keyList[index];
    }
    
}


contract HitchensUnorderedKeySet is Ownable {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set set;
    
    event LogUpdate(address sender, string action, bytes32 key);
    
    function exists(bytes32 key) public view returns(bool) {
        return set.exists(key);
    }
    
    function insert(bytes32 key) public {
        set.insert(key);
        emit LogUpdate(msg.sender, "insert", key);
    }
    
    function remove(bytes32 key) public {
        set.remove(key);
        emit LogUpdate(msg.sender, "remove", key);
    }
    
    function count() public view returns(uint) {
        return set.count();
    }
    
    function keyAtIndex(uint index) public view returns(bytes32) {
        return set.keyAtIndex(index);
    }
    
}
