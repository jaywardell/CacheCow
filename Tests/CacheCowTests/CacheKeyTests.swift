//
//  CacheKeyTests.swift
//  CacheCow
//
//  Created by Joseph Wardell on 12/17/24.
//

import Testing

import CacheCow

struct CacheKeyTests {

    struct stringToKey {
        @Test func empty_returns_empty() async throws {
            let expected = ""
            #expect(cacheValue(of:expected) == expected)
        }

        @Test(
            "Simple Words",
            arguments: [
                "burger",
                "cat",
                "running",
                "fantabulous",
                "honorific"
            ]
        )
        func word_returns_word(_ string: String) async throws {
            let expected = string
            #expect(cacheValue(of:string) == expected)
        }
        
        @Test(
            "Phrases",
            arguments: [
                ("burger shop", "shopburger"),
                ("cat burglar", "burglarcat"),
                ("I love running", "runningloveI"),
                ("fantabulous stupednous marvelous", "marvelousstupednousfantabulous"),
                ("so\thonorific", "honorificso")
            ]
        )
        func words_returns_words_without_spaces(_ strings: (String, String)) async throws {
            #expect(cacheValue(of:strings.0) == strings.1)
        }

        @Test(
            "URLs and other punctuation",
            arguments: [
                ("https://developer.apple.com/documentation/testing/parameterizedtesting", "parameterizedtestingtestingdocumentationcomappledeveloperhttps"),
                ("https://swiftwithmajid.com/2024/11/12/introducing-swift-testing-parameterized-tests/", "testsparameterizedtestingswiftintroducing12112024comswiftwithmajidhttps"),
                ("The great manda eats, shoots, and leaves.", "leavesandshootseatsmandagreatThe")
            ]
        )
        func punctuation_returns_words_without_punctuation_reversed(_ strings: (String, String)) async throws {
            #expect(cacheValue(of:strings.0) == strings.1)
        }

    }

}
