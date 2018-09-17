//
// Copyright 2017 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import RealmSwift

public protocol RealmQuery : Query {
    var realmPredicate : NSPredicate { get }
}

extension NSPredicate : RealmQuery {
    public var realmPredicate : NSPredicate {
        get { return self }
    }
}

public class RealmDataSource <E: Entity, O: Object> : DataSource {
    
    public typealias T = E
    
    let realmHandler: RealmHandler
    let toEntityMapper: Mapper<O,E>
    let toRealmMapper: RealmMapper<E,O>
    
    public init(realmHandler: RealmHandler,
                toEntityMapper: Mapper<O,E>,
                toRealmMapper: RealmMapper<E,O>) {
        self.realmHandler = realmHandler
        self.toEntityMapper = toEntityMapper
        self.toRealmMapper = toRealmMapper
    }
    
    public func get(_ query: Query) -> Future<E> {
        switch query {
        case let query as IdQuery<String>:
            return realmHandler.read { realm in
                return realm.object(ofType: O.self, forPrimaryKey: query.id)
                }.map { try self.toEntityMapper.map($0) }
        default:
            fatalError()
        }
    }
    
    public func getAll(_ query: Query) -> Future<[E]> {
        switch query {
        case is AllObjectsQuery:
            return realmHandler.read { realm in
                return Array(realm.objects(O.self))
                }.map { try self.toEntityMapper.map($0) }
        case let query as RealmQuery:
            return realmHandler.read { realm in
                return Array(realm.objects(O.self).filter(query.realmPredicate))
                }.map { try self.toEntityMapper.map($0) }
        default:
            fatalError()
        }
    }
    
    @discardableResult
    public func put(_ value: E?, in query: Query) -> Future<E> {
        switch query {
        case is VoidQuery:
            guard let value = value else {
                return Future(CoreError.IllegalArgument("Value cannot be nil"))
            }
            return realmHandler.write { realm in
                let object = try toRealmMapper.map(value, inRealm: realm)
                realm.add(object)
                return object
                }.map { try self.toEntityMapper.map($0) }
        case let query as ObjectQuery<E>:
            if value != nil {
                return Future(CoreError.IllegalArgument("Value parameter must be nil when using an ObjectQuery"))
            }
            return put(query.object, in: VoidQuery())
        default:
            fatalError()
        }
    }
    
    @discardableResult
    public func putAll(_ array: [E], in query: Query) -> Future<[E]> {
        switch query {
        case is VoidQuery:
            return realmHandler.write { realm -> [O] in
                let objetcs = try array.map { try toRealmMapper.map($0, inRealm:realm) }
                objetcs.forEach { realm.add($0, update: true) }
                return objetcs
                }.map { try self.toEntityMapper.map($0) }
        case is AllObjectsQuery:
            return putAll(array, in: VoidQuery())
        case let query as ArrayQuery<E>:
            if array.count > 0 {
                return Future(CoreError.IllegalArgument("Parameter array must be empty when using an ArrayQuery"))
            }
            return putAll(query.array, in: VoidQuery())
        default:
            fatalError()
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as IdQuery<String>:
            return realmHandler.write { realm in
                if let object = realm.object(ofType: O.self, forPrimaryKey: query.id) {
                    realm.delete(object)
                }
                return Void()
            }
        case let query as ObjectQuery<E>:
            return realmHandler.write { realm in
                if query.object.id == nil {
                    throw CoreError.IllegalArgument("The object Id must be not nil")
                }
                let object = try toRealmMapper.map(query.object, inRealm: realm)
                realm.delete(object)
                return Void()
            }
        default:
            fatalError()
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as ArrayQuery<E>:
            return realmHandler.write { realm in
                try query.array
                    .map { try toRealmMapper.map($0, inRealm: realm) }
                    .forEach { realm.delete($0) }
                return Void()
                }
        case is AllObjectsQuery:
            return realmHandler.write { realm in
                realm.objects(O.self).forEach { realm.delete($0) }
                return Void()
                }
        case let query as RealmQuery:
            return realmHandler.write { realm in
                realm.objects(O.self).filter(query.realmPredicate).forEach { realm.delete($0) }
                return Void()
                }
        default:
            fatalError()
        }
    }
}
