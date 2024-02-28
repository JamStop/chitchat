// Created by Jimmy Yue in 2024

import Foundation

func firebaseEncode<A: Encodable>(_ encodable: A) -> [String: Any]? {
    return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(encodable))) as? [String: Any]
}

func firebaseDecode<A: Decodable>(dict: [String: Any]) throws -> A {
    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
    return try JSONDecoder().decode(A.self, from: jsonData)
}
