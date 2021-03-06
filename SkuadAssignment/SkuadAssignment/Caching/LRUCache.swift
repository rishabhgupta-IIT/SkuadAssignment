//
//  LRUCache.swift
//  SkuadAssignment
//
//  Created by Rishabh Gupta on 2021-02-21.
//

import Foundation

/**
 * LRU Cache implementation using doubly link list and map
 */

class Node {
    var prev: Node?
    var next: Node?
    var key: String
    var value: String
    
    init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
}

class LRUCache: NSObject {
    
    /**
     * Shared instance
     */
    static var sharedInstance = LRUCache(10)
    
    var capacity: Int
    var head = Node("-1", "-1")
    var trail = Node("-1", "-1")
    var map = [String: Node]()
    var count = 0
    
    private init(_ capacity: Int) {
        self.capacity = capacity
        head.next = trail
        trail.prev = head
    }
    
    func removeNode(_ node: Node) {
        node.prev?.next = node.next
        node.next?.prev = node.prev
    }
    
    func moveToHead(_ node: Node) {
        node.prev = head
        node.next = head.next
        head.next = node
        node.next?.prev = node
    }
    
    func get() -> [String] {
        var arr = [String]()
        var node = head.next
        while node?.next !=  nil {
            if let node = node {
                arr.append(node.key)
            }
            node = node?.next
        }
        return arr
    }
    
    func put(_ key: String, _ value: String) {
        if let node = map[key] {
            removeNode(node)
            moveToHead(node)
            node.value = value
        }
        else {
            let node = Node(key, value)
            if count == capacity {
                map[trail.prev!.key] = nil
                removeNode(trail.prev!)
                count -= 1
            }
            map[key] = node
            moveToHead(node)
            count += 1
        }
    }
}
