/**
 * @author Saksham saini
 * @email sakshamsainisaini94@gmail.com
 * @create date 2024-06-15
 * @modify date 2024-06-26 
 */

import React, { Component } from 'react';
import { supplierContract, customerContract, web3 } from "./EthereumSetup";
import { Grid, Row, Col, Panel, Tabs, Tab, Table } from 'react-bootstrap';
import './App.css';

class CustomersClient extends Component {

    constructor(props) {
        super(props);
        this.state = {
            supplierContract_blockchainRecordedItemIds: [],
            customerContract_blockchainRecordedPurchaseOrderIds: []
        };

        /* event listeners */
        this.supplierContract_itemAddedEvents = supplierContract.ItemAdded({}, {
            fromBlock: 0,
            toBlock: 'latest'
        });

        this.supplierContract_processAnOrderEvents = supplierContract.ProcessAnOrder({}, {
            fromBlock: 0,
            toBlock: 'latest'
        });

        this.customerContract_OrderRaisedOrUpdatedEvents = customerContract.OrderRaisedOrUpdated({}, {
            fromBlock: 0,
            toBlock: 'latest'
        });

        /* Getters */
        this.supplierContract_getItem = this.supplierContract_getItem.bind(this);
        this.supplierContract_getStatus = this.supplierContract_getStatus.bind(this);
        this.customerContract_getOrderDetails = this.customerContract_getOrderDetails.bind(this);
        this.customerContract_getNumberOfItemsPurchased = this.customerContract_getNumberOfItemsPurchased.bind(this);
        this.customerContract_getNumberOfItemsReceived = this.customerContract_getNumberOfItemsReceived.bind(this);

        /* transactions */
        this.customerContract_purchaseItem = this.customerContract_purchaseItem.bind(this);
        this.customerContract_recieveItem = this.customerContract_recieveItem.bind(this);

        this.triggerCustomerContractEventListeners = this.triggerCustomerContractEventListeners.bind(this);
        this.purchaseThisItem = this.purchaseThisItem.bind(this);
    }

    componentDidMount(){
        this.triggerCustomerContractEventListeners();
    }

    triggerCustomerContractEventListeners() {

        this.supplierContract_itemAddedEvents.watch((err, eventLogs) => {
            if (err) {
                console.error('[Event Listener Error]', err);
            } else {
                console.log('[Event Logs]', eventLogs);
                this.setState({
                    supplierContract_blockchainRecordedItemIds: [...this.state.supplierContract_blockchainRecordedItemIds,
                        parseInt(eventLogs.args.idItem.toString())
                    ]
                });
            }
        });

        this.customerContract_OrderRaisedOrUpdatedEvents.watch((err, eventLogs) => {
            if (err) {
                console.error('[Event Listener Error]', err);
            } else {
                console.log('[Event Logs]', eventLogs);
                this.setState({
                    customerContract_blockchainRecordedPurchaseOrderIds: [...this.state.customerContract_blockchainRecordedPurchaseOrderIds,
                        parseInt(eventLogs.args.idOrder.toString())
                    ]
                });
            }
        });

        this.supplierContract_processAnOrderEvents.watch((err, eventLogs) => {
            if (err) {
                console.error('[Event Listener Error]', err);
            } else {
                console.log('[Event Logs]', eventLogs);
                if (eventLogs.args.status){
                    this.customerContract_recieveItem(parseInt(eventLogs.args.idOrder.toString()));
                }
            }
        })
    }

    supplierContract_getItem(idItem) {
        return supplierContract.getItem.call(idItem);
    }
    supplierContract_getStatus(idOrder) {
        return supplierContract.getStatus.call(idOrder);
    }

    customerContract_getOrderDetails(idOrder) {
        return customerContract.getOrderDetails.call(idOrder);
    }
    customerContract_getNumberOfItemsPurchased() {
        return customerContract.getNumberOfItemsPurchased.call();
    }
    customerContract_getNumberOfItemsReceived() {
        return customerContract.getNumberOfItemsReceived.call();
    }

    customerContract_purchaseItem(itemName, quantity) {
        customerContract.purchaseItem(itemName, quantity, {
            from: web3.eth.accounts[0],
            gas: 200000
        }, (err, results) => {
            if (err) {
                console.error('[Customer Contract] Error during purchasing an item', err);
            } else {
                console.log('[Customer Contract] - item purchased', results.toString());
            }
        });
    }

    customerContract_recieveItem(idOrder) {
        customerContract.recieveItem(idOrder, {
            from: web3.eth.accounts[0],
            gas: 200000
        }, (err, results) => {
            if (err) {
                console.error('[Customer Contract] Error during recieving ordered item', err);
            } else {
                console.log('[Customer Contract] - item recieved successfully!', results.toString());
            }
        });
    }

    purchaseThisItem(itemDetails){
        this.customerContract_purchaseItem(itemDetails.itemName, itemDetails.quantity);
    }


    render(){
        return (
            <div>
                <Grid>
                    <Row className="show-grid">
                        <Col xs={12} md={6}>
                            <Panel>
                                <Panel.Heading>Customer Section</Panel.Heading>
                                <Panel.Body>
                                    <Tabs defaultActiveKey={1} id="uncontrolled-tab-example">
                                        <Tab eventKey={1} title="Market">
                                            {this.state.supplierContract_blockchainRecordedItemIds.map(itemId => {
                                                let itemDetails = this.supplierContract_getItem(itemId);
                                                return (
                                                    <div>
                                                        <Panel onClick={() => this.purchaseThisItem({
                                                            'id': itemId,
                                                            'itemName': web3.toUtf8(String(itemDetails).split(',')[0]),
                                                            'price': parseInt(String(itemDetails).split(',')[1]),
                                                            'quantity': 1
                                                        })}>
                                                            <Panel.Heading className="pointIt">HOT SALE! <small>Click to purchase!</small></Panel.Heading>
                                                            <Panel.Body>
                                                                {web3.toUtf8(String(itemDetails).split(',')[0])} @ ${parseInt(String(itemDetails).split(',')[1])}
                                                            </Panel.Body>
                                                        </Panel>
                                                    </div>
                                                );
                                            })}
                                        </Tab>
                                        <Tab eventKey={2} title="Order(s)">
                                            <h4>Order details</h4>
                                            <Table striped bordered condensed hover>
                                                <thead>
                                                    <tr>
                                                    <th>Order ID</th>
                                                    <th>Item Name</th>
                                                    <th>Quantity</th>
                                                    <th>Order Completed</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {
                                                    [... new Set(this.state.customerContract_blockchainRecordedPurchaseOrderIds)].map(orderId => {
                                                        const orderDetails = this.customerContract_getOrderDetails(orderId);

                                                        return (<tr>
                                                            <td>
                                                            {orderId}
                                                            </td>
                                                            <td>
                                                            {web3.toUtf8(String(orderDetails).split(',')[0])}
                                                            </td>
                                                            <td>
                                                            {parseInt(String(orderDetails).split(',')[1])}
                                                            </td>
                                                            <td>
                                                            {String(orderDetails).split(',')[2]}
                                                            </td>
                                                        </tr>);
                                                    }
                                                )}
                                                </tbody>
                                            </Table>
                                        </Tab>
                                    </Tabs>
                                </Panel.Body>
                            </Panel>
                        </Col>
                    </Row>
                </Grid>
            </div>
        );
    }

}

export default CustomersClient;
