import React from "react";
import { View } from "react-native";
import Drake from "./Drake";

const Chips = ({ flexValue }: { flexValue: number }) => {
    return (
      <View style={{ flex: flexValue }}>
          <Drake/>
      </View>
    );
  };



// const styles = {

// }

export default Chips;