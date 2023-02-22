import ballerina/log;
import ballerinax/mysql;
import ballerina/graphql;
import ballerina/sql;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string db = ?;
configurable int port = ?;

type Catalog record {
    int id;
    string title;
    string description?;
    string includes;
    string intended?;
    string color;
    string material;
    float price;
};

type Cart record {
    int id;
    string userId;
    int catalogId;
    string quantity;
    string cardDetails?;
    boolean checkedOut;
    string createdAt;
};

service /graphql on new graphql:Listener(9090) {
    private mysql:Client mySqlClient;
    function init() returns error? {
        self.mySqlClient = check new (host, username, password, db, port, connectionPool = {maxOpenConnections: 3});
    }

    resource function get catalog() returns Catalog[]|error {
        // TODO add following db params as secrets
        stream<Catalog, sql:Error?> result = self.mySqlClient->query(`select * from catalog;`);

        Catalog[] catalogArr = check from Catalog catalog in result
            select catalog;
        log:printInfo("Catalog array: ", catalog = catalogArr);
        return catalogArr;
    }

    resource function get cart(string userId) returns Cart|error {
        // TODO add mysql client as a field in init()
        Cart|sql:Error cart = self.mySqlClient->queryRow(`select * from cart where userId = ${userId};`);
        if cart is Cart {
            return cart;
        } else {
            log:printError("Error while retrieving cart: ", cart);
            return error("Error while retrieving cart");
        }
    }
}

