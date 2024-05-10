// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.6;

import {CBOR, Buffer} from "../vendor/CBOR.sol";

/**
 * @title Library for Chainlink Functions
 */
library Functions {
    uint256 internal constant DEFAULT_BUFFER_SIZE = 256; // solhint-disable-line const-name-snakecase

    using CBOR for Buffer.buffer;

    enum Location {
        Inline,
        Remote
    }

    enum CodeLanguage {
        Javascript
    }
    // In future versions, we can add more languages here

    struct Request {
        Location codeLocation;
        Location secretsLocation;
        CodeLanguage language;
        string source; // source code Location.Inline or url for location.Remote
        bytes secrets; // Encrypted secrets blob for Location.Inline or url for Location.Remote
        string[] args;
    }

    error EmptySource();
    error EmptyUrl();
    error EmptySecrets();
    error EmptyArgs();
    error NoInlineSecrets();

    /**
     * @notice Encodes a Request to CBOR encoded types
     * @param self The request to encode
     * @return CBOR encoded bytes
     */
    function encodeCBOR(Request memory self) internal pure returns (bytes memory) {
        CBOR.CBORBuffer memory buffer;
        Buffer.init(buffer.buf, DEFAULT_BUFFER_SIZE);

        CBOR.writeString(buffer, "codeLocation");
        CBOR.writeUInt256(buffer, uint256(self.codeLocation));

        CBOR.writeString(buffer, "source");
        CBOR.writeString(buffer, self.source);

        if (self.args.length > 0) {
            CBOR.writeString(buffer, "args");
            CBOR.startArray(buffer);
            for (uint256 i; i < self.args.length; i++) {
                CBOR.writeString(buffer, self.args[i]);
            }
            CBOR.endSequence(buffer);
        }

        if (self.secrets.length > 0) {
            if (self.secretsLocation == Location.Inline) {
                revert NoInlineSecrets();
            }
            CBOR.writeString(buffer, "secretsLocation");
            CBOR.writeUInt256(buffer, uint256(self.secretsLocation));
            CBOR.writeString(buffer, "secrets");
            CBOR.writeBytes(buffer, self.secrets);
        }

        return buffer.buf.buf;
    }

    /**
     * @notice Initializes a Chainlink Functions Request
     * @dev Sets the codeLocation and code on the request
     * @param self the uninitialized request
     * @param location the user provided source code location
     * @param language the programming language of the user code
     * @param source the user provided source code or a url
     */
    function initializeRequest(Request memory self, Location location, CodeLanguage language, string memory source)
        internal
        pure
    {
        if (bytes(source).length == 0) revert EmptySource();

        self.codeLocation = location;
        self.language = language;
        self.source = source;
    }

    /**
     * @notice Initializes a Chainlink Functions Request
     * @dev Simplified version of initializeRequest with no secrets
     * @param self The uninitialized request
     * @param javaScriptSource The user provided JS code (must not be empty)
     */
    function initializeRequestInlineJavascript(Request memory self, string memory javaScriptSource) internal pure {
        initializeRequest(self, Location.Inline, CodeLanguage.Javascript, javaScriptSource);
    }

    /**
     * @notice Adds Remote user encrypted secrets to a Request
     * @param self The initalized request
     * @param encryptedSecretsURLs Encrypted comma-separated string of URLs pointing to off-chain secrets
     */
    function addRemoteSecrets(Request memory self, bytes memory encryptedSecretsURLs) internal pure {
        if (encryptedSecretsURLs.length == 0) revert EmptySecrets();

        self.secretsLocation = Location.Remote;
        self.secrets = encryptedSecretsURLs;
    }

    /**
     * @notice Adds args for the user run function
     * @param self the Initialized request
     * @param args The array of args (must not be empty)
     */
    function addArgs(Request memory self, string[] memory args) internal pure {
        if (args.length == 0) revert EmptyArgs();

        self.args = args;
    }
}
