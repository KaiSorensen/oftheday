import React from "react";
import { View, Text, StyleSheet } from "react-native"; // Import StyleSheet from react-native
import Header from "./Header";
import Chips from "./Chips";
import Content from "./Content";

const Main = () => {
  return (
    <View style={styles.container}>
        <Header flexValue={1.5}/>
        <Chips flexValue={1}/>
        <Content flexValue={5}/>
    </View>
  );
};

const styles = StyleSheet.create({
    container: {
      flex: 1,
    },
  });

export default Main;