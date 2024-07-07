import React from "react";
import { View, StyleSheet } from "react-native";
import { SafeAreaView } from 'react-native-safe-area-context';
import Header from "./Header";
import Chips from "./Chips";
import Content from "./Content";

const Main = () => {
  return (
      <View style={styles.safeArea}>
        <Header flexValue={1.5} />
        <Chips flexValue={1} />
        <Content flexValue={5} />
      </View>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: 'purple', // Set your desired background color
  },
  container: {
    flex: 1,
  },
});

export default Main;
