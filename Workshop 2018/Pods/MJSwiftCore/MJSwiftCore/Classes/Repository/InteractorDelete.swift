//
// Copyright 2018 Mobile Jazz SL
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

extension Interactor {
    ///
    /// Generic delete object by query interactor
    ///
    public class DeleteByQuery<T> {
        
        private let executor : Executor
        private let repository: AnyDeleteRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R) where R : DeleteRepository, R.T == T {
            self.executor = executor
            self.repository = repository.asAnyDeleteRepository()
        }
        
        @discardableResult
        public func execute(_ query: Query, operation: Operation = VoidOperation(), in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(query, operation: operation))
            }
        }
        
        @discardableResult
        public func execute<K>(_ id: K, operation: Operation = VoidOperation(), in executor: Executor? = nil) -> Future<Void> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic delete object interactor
    ///
    public class Delete<T> {
        
        private let query : Query
        private let executor : Executor
        private let repository: AnyDeleteRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R, _ query: Query) where R : DeleteRepository, R.T == T {
            self.query = query
            self.executor = executor
            self.repository = repository.asAnyDeleteRepository()
        }
        
        public convenience init<R,K>(_ executor: Executor, _ repository: R, _ id: K) where K : Hashable, R : DeleteRepository, R.T == T {
            self.init(executor, repository, IdQuery(id))
        }
        
        @discardableResult
        public func execute(_ operation: Operation = VoidOperation(), in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(self.query, operation: operation))
            }
        }
    }
    
    ///
    /// Generic delete objects interactor
    ///
    public class DeleteAllByQuery<T> {
        
        private let executor : Executor
        private let repository: AnyDeleteRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R) where R : DeleteRepository, R.T == T {
            self.executor = executor
            self.repository = repository.asAnyDeleteRepository()
        }
        
        @discardableResult
        public func execute(_ query: Query, operation: Operation = VoidOperation(), in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(query, operation: operation))
            }
        }
        
        @discardableResult
        public func execute<K>(_ id: K, operation: Operation = VoidOperation(), in executor: Executor? = nil) -> Future<Void> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic delete objects interactor
    ///
    public class DeleteAll<T> {
        
        private let query : Query
        private let executor : Executor
        private let repository: AnyDeleteRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R, _ query: Query) where R : DeleteRepository, R.T == T {
            self.query = query
            self.executor = executor
            self.repository = repository.asAnyDeleteRepository()
        }
        
        public convenience init<R,K>(_ executor: Executor, _ repository: R, _ id: K) where K : Hashable, R : DeleteRepository, R.T == T {
            self.init(executor, repository, IdQuery(id))
        }
        
        @discardableResult
        public func execute(_ operation: Operation = VoidOperation(), in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(self.query, operation: operation))
            }
        }
    }
}
